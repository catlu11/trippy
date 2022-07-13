//
//  ParseUtils.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "ParseUtils.h"
#import "Parse/Parse.h"
#import "Itinerary.h"

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
    [locationQuery includeKeys:[self getLocationKeys]];
    locObj = [locationQuery getObjectWithId:locObj.objectId];
    // get location
    it.originLocation = [[Location alloc] initWithPFObj:locObj];
    
    // query collection pointer
    PFObject *colObj = obj[@"sourceCollection"];
    PFQuery *colQuery = [PFQuery queryWithClassName:@"Collection"];
    [colQuery includeKeys:[self getCollectionKeys]];
    colObj = [colQuery getObjectWithId:colObj.objectId];
    [LocationCollection initFromPFObj:colObj completion:^(LocationCollection * _Nonnull col, NSError * _Nonnull error) {
        if (col) {
            it.sourceCollection = col;
            completion(it, nil);
        }
    }];
}

+ (PFObject *)pfObjFromItinerary:(Itinerary *)it {
    if (it.parseObjectId != nil) {
        PFQuery *query = [PFQuery queryWithClassName:@"Itinerary"];
        return [query getObjectWithId:it.parseObjectId];
    }
    else {
        PFObject *obj = [PFObject objectWithClassName:@"Itinerary"];
        obj[@"name"] = it.name;
        obj[@"createdBy"] = [PFUser currentUser];
        obj[@"origin"] = [it.originLocation getPfObjRepresentation];
        obj[@"sourceCollection"] = [it.sourceCollection getPfObjRepresentation];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:it.directionsJson options:0 error:nil];
        PFFileObject *jsonFile = [PFFileObject fileObjectWithName:@"directions.json" data:jsonData];
        obj[@"directionsJson"] = jsonFile;
        return obj;
    }
}

@end
