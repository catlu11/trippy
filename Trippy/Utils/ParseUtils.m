//
//  ParseUtils.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "ParseUtils.h"
#import "Location.h"

@implementation ParseUtils

+ (NSArray *)getCollectionKeys {
    return @[@"updatedAt", @"createdAt", @"title", @"snippet", @"createdBy", @"locations"];
}

+ (NSArray *)getLocationKeys {
    return @[@"updatedAt", @"createdAt", @"title", @"snippet", @"createdBy", @"placeId", @"coord"];
}

+ (NSString *)getLoggedInUserId {
    return [PFUser currentUser].username;
}

+ (void) collectionFromPFObj:(PFObject *)obj completion:(void (^)(Collection *collection, NSError *))completion {
    Collection *newColl = [[Collection alloc] init];
    PFUser *user = obj[@"createdBy"];
    
    newColl.title = obj[@"title"];
    newColl.snippet = obj[@"snippet"];
    newColl.userId = user.username;
    newColl.lastUpdated = obj.updatedAt;
    newColl.createdAt = obj.createdAt;
    newColl.objectId = obj.objectId;
    
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
    return [[Location alloc] initWithParams:obj[@"title"] snippet:obj[@"snippet"] latitude:coord.latitude longitude:coord.longitude user:user.username placeId:obj[@"placeId"] objectId:obj.objectId];
}

+ (PFObject *)newPFObjFromCollection:(Collection *)collection {
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

+ (PFObject *)newPFObjFromLocation:(Location *)loc {
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
    [query whereKey:@"objectId" equalTo:loc.objectId];
    return [query getFirstObject];
}

@end
