//
//  ParseUtils.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "ParseUtils.h"
#import "Parse/Parse.h"
#import "Itinerary.h"
#import "LocationCollection.h"
#import "Location.h"

@implementation ParseUtils

+ (NSArray *)getCollectionKeys {
    return @[@"updatedAt", @"createdAt", @"title", @"snippet", @"createdBy", @"locations"];
}

+ (NSArray *)getLocationKeys {
    return @[@"updatedAt", @"createdAt", @"title", @"snippet", @"createdBy", @"placeId", @"types", @"priceLevel", @"coord"];
}

+ (NSArray *)getItineraryKeys {
    return @[@"directionsJson", @"createdAt", @"name", @"createdBy", @"origin", @"startCoord", @"sourceCollection", @"departure", @"mileageConstraint", @"budgetConstraint", @"isFavorited", @"staticMap"];
}

+ (NSString *)getLoggedInUsername {
    return [PFUser currentUser].username;
}

+ (PFFileObject *)pfFileFromDict:(NSDictionary *)dict name:(NSString *)name {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *filename = [NSString stringWithFormat:@"%@.json", name];
    PFFileObject *jsonFile = [PFFileObject fileObjectWithName:filename data:jsonData];
    return jsonFile;
}

+ (PFFileObject *)pfFileFromImage:(UIImage *)img name:(NSString *)name {
    NSData *data = UIImagePNGRepresentation(img);
    NSString *filename = [NSString stringWithFormat:@"%@.png", name];
    PFFileObject *file = [PFFileObject fileObjectWithName:filename data:data];
    return file;
}

+ (NSDictionary *)dictFromPfFile:(PFFileObject *)file {
    NSData *data = [file getData:nil];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

+ (UIImage *)imgFromPfFile:(PFFileObject *)file {
    NSData *data = [file getData:nil];
    return [UIImage imageWithData:data];
}

+ (void) itineraryFromPFObj:(PFObject *)obj completion:(void (^)(Itinerary *itinerary, NSError *))completion {
    PFFileObject *routesJsonFile = obj[@"directionsJson"];
    NSDictionary *routesDict = [self dictFromPfFile:routesJsonFile];

    PFFileObject *prefsJsonFile = obj[@"preferencesJson"];
    NSDictionary *prefsDict = [self dictFromPfFile:prefsJsonFile];
    
    PFFileObject *imgFile = obj[@"staticMap"];
    UIImage *img = [self imgFromPfFile:imgFile];
    
    __block Location *originLocation = nil;
    __block LocationCollection *sourceCollection = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_group_t group = dispatch_group_create();
        
        // query location pointer
        dispatch_group_enter(group);
        PFObject *locObj = obj[@"origin"];
        PFQuery *locationQuery = [PFQuery queryWithClassName:@"Location"];
        [locationQuery includeKeys:[self getLocationKeys]];
        [locationQuery getObjectInBackgroundWithId:locObj.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if (object) {
                originLocation = [self locationFromPFObj:object];
            }
            dispatch_group_leave(group);
        }];
        
        // query collection pointer
        dispatch_group_enter(group);
        PFObject *colObj = obj[@"sourceCollection"];
        PFQuery *colQuery = [PFQuery queryWithClassName:@"Collection"];
        [colQuery includeKeys:[self getCollectionKeys]];
        [colQuery getObjectInBackgroundWithId:colObj.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
            [self collectionFromPFObj:object completion:^(LocationCollection * _Nonnull collection, NSError * _Nonnull) {
                if (collection) {
                    sourceCollection = collection;
                }
                dispatch_group_leave(group);
            }];
        }];
        
        // create itinerary
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            Itinerary *it = [[Itinerary alloc] initWithDictionary:routesDict
                                                         prefJson:prefsDict
                                                        departure:obj[@"departure"]
                                                mileageConstraint:obj[@"mileageConstraint"]
                                                 budgetConstraint:obj[@"budgetConstraint"]
                                                 sourceCollection:sourceCollection
                                                   originLocation:originLocation
                                                             name:obj[@"name"]
                                                      isFavorited:[obj[@"isFavorited"] boolValue]];
            PFUser *user = [obj[@"createdBy"] fetchIfNeeded];
            it.userId = user.username;
            it.createdAt = obj.createdAt;
            it.parseObjectId = obj.objectId;
            it.staticMap = img;
            completion(it, nil);
        });
    });
}

+ (void) collectionFromPFObj:(PFObject *)obj completion:(void (^)(LocationCollection *collection, NSError *))completion {
    LocationCollection *newColl = [[LocationCollection alloc] init];
    PFUser *user = [obj[@"createdBy"] fetchIfNeeded];
    
    newColl.title = obj[@"title"];
    newColl.snippet = obj[@"snippet"];
    newColl.userId = user.username;
    newColl.lastUpdated = obj.updatedAt;
    newColl.createdAt = obj.createdAt;
    newColl.parseObjectId = obj.objectId;
    
    // query locations
    PFRelation *locations = obj[@"locations"];
    PFQuery *locationsQuery = [locations query];
    [locationsQuery orderByDescending:@"updatedAt"];
    [locationsQuery includeKeys:[ParseUtils getLocationKeys]];
    [locationsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error querying location relation: %@", error.description);
            completion(nil, error);
        } else {
            NSMutableArray *newLocations = [[NSMutableArray alloc] init];
            for (PFObject *loc in objects) {
                [newLocations addObject:[ParseUtils locationFromPFObj:loc]];
            }
            newColl.locations = newLocations;
            completion(newColl, nil);
        }
    }];
}

+ (Location *)locationFromPFObj:(PFObject *)obj {
    PFGeoPoint *coord = obj[@"coord"];
    PFUser *user = [obj[@"createdBy"] fetchIfNeeded];
    return [[Location alloc] initWithParams:obj[@"title"] snippet:obj[@"snippet"] latitude:coord.latitude longitude:coord.longitude user:user.username placeId:obj[@"placeId"] types:obj[@"types"] priceLevel:obj[@"priceLevel"] parseObjectId:obj.objectId];
}

+ (void)pfObjFromCollection:(LocationCollection *)collection completion:(void (^)(PFObject *obj, NSError *))completion {
    if (collection.parseObjectId != nil) {
        PFQuery *query = [PFQuery queryWithClassName:@"Collection"];
        [query includeKeys:[ParseUtils getCollectionKeys]];
        [query getObjectInBackgroundWithId:collection.parseObjectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if (object) {
                completion(object, nil);
            } else {
                completion(nil, error);
            }
        }];
    } else {
        PFObject *obj = [PFObject objectWithClassName:@"Collection"];
        obj[@"title"] = collection.title;
        obj[@"snippet"] = collection.snippet;
        obj[@"createdBy"] = [PFUser currentUser];
        PFRelation *relation = [obj relationForKey:@"locations"];
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_group_t group = dispatch_group_create();
            for(Location *loc in collection.locations) {
                dispatch_group_enter(group);
                [self pfObjFromLocation:loc completion:^(PFObject * _Nonnull newObj, NSError * _Nonnull) {
                    [relation addObject: newObj];
                    dispatch_group_leave(group);
                }];
            }
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                completion(obj, nil);
            });
        });
    }
}

+ (void)pfObjFromLocation:(Location *)loc completion:(void (^)(PFObject *obj, NSError *))completion {
    if (loc.parseObjectId != nil) {
        PFQuery *query = [PFQuery queryWithClassName:@"Location"];
        [query includeKeys:[ParseUtils getLocationKeys]];
        [query getObjectInBackgroundWithId:loc.parseObjectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if (object) {
                completion(object, nil);
            } else {
                completion(nil, error);
            }
        }];
    } else {
        PFObject *obj = [PFObject objectWithClassName:@"Location"];
        obj[@"placeId"] = loc.placeId;
        obj[@"title"] = loc.title;
        obj[@"snippet"] = loc.snippet;
        obj[@"coord"] = [PFGeoPoint geoPointWithLatitude:loc.coord.latitude longitude:loc.coord.longitude];
        obj[@"createdBy"] = [PFUser currentUser];
        obj[@"types"] = loc.types;
        obj[@"priceLevel"] = loc.priceLevel;
        completion(obj, nil);
    }
}

+ (void)pfObjFromItinerary:(Itinerary *)it completion:(void (^)(PFObject *obj, NSError *))completion {
    if (it.parseObjectId != nil) {
        PFQuery *query = [PFQuery queryWithClassName:@"Itinerary"];
        [query includeKeys:[ParseUtils getItineraryKeys]];
        [query getObjectInBackgroundWithId:it.parseObjectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if (object) {
                completion(object, nil);
            } else {
                completion(nil, error);
            }
        }];
    } else {
        PFObject *obj = [PFObject objectWithClassName:@"Itinerary"];
        obj[@"name"] = it.name;
        obj[@"createdBy"] = [PFUser currentUser];
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_group_t group = dispatch_group_create();
            dispatch_group_enter(group);
            [self pfObjFromLocation:it.originLocation completion:^(PFObject * _Nonnull newObj, NSError * _Nonnull) {
                if (obj) {
                    obj[@"origin"] = newObj;
                    obj[@"startCoord"] = [newObj valueForKey:@"coord"];
                }
                dispatch_group_leave(group);
            }];
            dispatch_group_enter(group);
            [self pfObjFromCollection:it.sourceCollection completion:^(PFObject * _Nonnull newObj, NSError * _Nonnull) {
                if (obj) {
                    obj[@"sourceCollection"] = newObj;
                }
                dispatch_group_leave(group);
            }];
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                obj[@"directionsJson"] = [self pfFileFromDict:[it toRouteDictionary] name:@"directions"];
                obj[@"preferencesJson"] = [self pfFileFromDict:[it toPrefsDictionary] name:@"preferences"];
                obj[@"departure"] = it.departureTime;
                obj[@"mileageConstraint"] = it.mileageConstraint;
                obj[@"budgetConstraint"] = it.budgetConstraint;
                obj[@"isFavorited"] = [NSNumber numberWithBool:it.isFavorited];
                if (it.staticMap) {
                    obj[@"staticMap"] = [self pfFileFromImage:it.staticMap name:@"img"];
                } else {
                    obj[@"staticMap"] = [NSNull null];
                }
                completion(obj, nil);
            });
        });
    }
}

@end
