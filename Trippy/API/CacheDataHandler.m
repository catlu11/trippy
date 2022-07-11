//
//  FetchSavedHandler.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "CacheDataHandler.h"
#import "LocationCollection.h"
#import "Parse/Parse.h"
#import "ParseUtils.h"

@implementation CacheDataHandler

- (void) postNewLocation:(Location *)location collection:(LocationCollection *)collection {
    PFObject *newLocation = [ParseUtils newPFObjWithLocation:location];
    location.parseObjectId = newLocation.objectId;
    __weak CacheDataHandler *self_weak_ = self;
    [newLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded) {
            PFQuery *query = [PFQuery queryWithClassName:@"Collection"];
            [query whereKey:@"objectId" equalTo:collection.parseObjectId];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                if (error) {
                    __strong CacheDataHandler *self = self_weak_;
                    [self.delegate generalRequestFail:error];
                } else {
                    PFRelation *relation = [object relationForKey:@"locations"];
                    [relation addObject:newLocation];
                    [object saveInBackground];
                }
            }];
        }
    }];
}

- (void) postNewCollection:(LocationCollection *)collection {
    PFObject *newCollection = [ParseUtils newPFObjWithCollection:collection];
    __weak CacheDataHandler *self_weak_ = self;
    [newCollection saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            __strong CacheDataHandler *self = self_weak_;
            collection.createdAt = newCollection.createdAt;
            collection.parseObjectId = newCollection.objectId;
            collection.lastUpdated = collection.createdAt;
            [self.delegate postedCollectionSuccess:collection];
        }
    }];
}

- (void) fetchSavedCollections {
    PFQuery *query = [PFQuery queryWithClassName:@"Collection"];
    [query whereKey:@"createdBy" equalTo:[PFUser currentUser]];
    [query includeKeys:[ParseUtils getCollectionKeys]];
    [query orderByDescending:@"updatedAt"];
    
    __weak CacheDataHandler *self_weak_ = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            __strong CacheDataHandler *self = self_weak_;
            [self.delegate generalRequestFail:error];
        } else {
            for(PFObject *obj in objects) {
                [ParseUtils collectionFromPFObj:obj completion:^(LocationCollection * _Nonnull collection, NSError * _Nonnull) {
                    __strong CacheDataHandler *self = self_weak_;
                    if(error) {
                        [self.delegate generalRequestFail:error];
                    } else {
                        [self.delegate addFetchedCollection:collection];
                    }
                }];
            }
        }
    }];
}

- (void) fetchSavedLocations {
    PFQuery *query = [PFQuery queryWithClassName:@"Location"];
    [query whereKey:@"createdBy" equalTo:[PFUser currentUser]];
    [query includeKeys:[ParseUtils getLocationKeys]];
    [query orderByDescending:@"createdAt"];
    
    __weak CacheDataHandler *self_weak_ = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        __strong CacheDataHandler *self = self_weak_;
        if (error) {
            [self.delegate generalRequestFail:error];
        } else {
            for(PFObject *obj in objects) {
                [self.delegate addFetchedLocation:[ParseUtils locationFromPFObj:obj]];
            }
        }
    }];
}

- (void) fetchSavedLocationsByCollection:(LocationCollection *)collection {
    // TODO: Implement
}

@end
