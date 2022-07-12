//
//  ParseUtils.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "ParseUtils.h"

@implementation ParseUtils

+ (NSArray *)getCollectionKeys {
    return @[@"updatedAt", @"createdAt", @"title", @"snippet", @"createdBy", @"locations"];
}

+ (NSArray *)getLocationKeys {
    return @[@"updatedAt", @"createdAt", @"title", @"snippet", @"createdBy", @"placeId", @"coord"];
}

+ (NSArray *)getItineraryKeys {
    return @[@"directionsJson", @"createdAt", @"name", @"createdBy", @"origin", @"sourceCollection"];
}

+ (NSString *)getLoggedInUsername {
    return [PFUser currentUser].username;
}

+ (void) itineraryFromPFObj:(PFObject *)obj completion:(void (^)(Itinerary *itinerary, NSError *))completion {
    PFFileObject *jsonFile = obj[@"directionsJson"];
    NSData *data = [jsonFile getData:nil];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    // create itinerary object
    Itinerary *it = [[Itinerary alloc] initWithDictionary:dict];
    it.name = obj[@"name"];
    PFUser *user = obj[@"createdBy"];
    it.userId = user.username;
    it.createdAt = obj.createdAt;
    it.parseObjectId = obj.objectId;
    
    // query location pointer
    PFObject *locObj = obj[@"origin"];
    PFQuery *locationQuery = [PFQuery queryWithClassName:@"Location"];
    [locationQuery whereKey:@"objectId" equalTo:locObj.objectId];
    [locationQuery includeKeys:[self getLocationKeys]];
    locObj = [locationQuery getFirstObject];
    // get location
    it.originLocation = [self locationFromPFObj:locObj];
    
    // query collection pointer
    PFObject *colObj = obj[@"sourceCollection"];
    PFQuery *colQuery = [PFQuery queryWithClassName:@"Collection"];
    [colQuery whereKey:@"objectId" equalTo:colObj.objectId];
    [colQuery includeKeys:[self getLocationKeys]];
    colObj = [colQuery getFirstObject];
    
    // get collection
    [self collectionFromPFObj:colObj completion:^(LocationCollection * _Nonnull collection, NSError * _Nonnull) {
        if (collection) {
            it.sourceCollection = collection;
            completion(it, nil);
        }
    }];
}

+ (void) collectionFromPFObj:(PFObject *)obj completion:(void (^)(LocationCollection *collection, NSError *))completion {
    LocationCollection *newColl = [[LocationCollection alloc] init];
    PFUser *user = obj[@"createdBy"];
    
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
    PFUser *user = obj[@"createdBy"];
    return [[Location alloc] initWithParams:obj[@"title"] snippet:obj[@"snippet"] latitude:coord.latitude longitude:coord.longitude user:user.username placeId:obj[@"placeId"] parseObjectId:obj.objectId];
}

+ (PFObject *)newPFObjWithCollection:(LocationCollection *)collection {
    PFObject *obj = [PFObject objectWithClassName:@"Collection"];
    obj[@"title"] = collection.title;
    obj[@"snippet"] = collection.snippet;
    obj[@"createdBy"] = [PFUser currentUser];
    PFRelation *relation = [obj relationForKey:@"locations"];
    for(Location *loc in collection.locations) {
        PFObject *newObj = [self oldPFObjFromLocation:loc];
        [relation addObject: newObj];
    }
    return obj;
}

+ (PFObject *)newPFObjWithLocation:(Location *)loc {
    PFObject *obj = [PFObject objectWithClassName:@"Location"];
    obj[@"placeId"] = loc.placeId;
    obj[@"title"] = loc.title;
    obj[@"snippet"] = loc.snippet;
    obj[@"coord"] = [PFGeoPoint geoPointWithLatitude:loc.coord.latitude longitude:loc.coord.longitude];
    obj[@"createdBy"] = [PFUser currentUser];
    return obj;
}

+ (PFObject *)oldPFObjFromLocation:(Location *)loc {
    PFQuery *query = [PFQuery queryWithClassName:@"Location"];
    [query whereKey:@"objectId" equalTo:loc.parseObjectId];
    return [query getFirstObject];
}

+ (PFObject *)oldPFObjFromCollection:(LocationCollection *)col {
    PFQuery *query = [PFQuery queryWithClassName:@"Collection"];
    [query whereKey:@"objectId" equalTo:col.parseObjectId];
    return [query getFirstObject];
}

+ (PFObject *)newPFObjFromItinerary:(Itinerary *)it {
    PFObject *obj = [PFObject objectWithClassName:@"Itinerary"];
    obj[@"name"] = it.name;
    obj[@"createdBy"] = [PFUser currentUser];
    obj[@"origin"] = [self oldPFObjFromLocation:it.originLocation];
    obj[@"sourceCollection"] = [self oldPFObjFromCollection:it.sourceCollection];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:it.directionsJson options:0 error:nil];
    PFFileObject *jsonFile = [PFFileObject fileObjectWithName:@"directions.json" data:jsonData];
    obj[@"directionsJson"] = jsonFile;
    return obj;
}

@end
