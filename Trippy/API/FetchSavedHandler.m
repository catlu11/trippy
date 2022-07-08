//
//  FetchSavedHandler.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "FetchSavedHandler.h"
#import "Collection.h"
#import "Parse/Parse.h"
#import "ParseUtils.h"

@implementation FetchSavedHandler

- (void) postNewLocation:(Location *)location collection:(Collection *)collection {
    PFObject *newLocation = [ParseUtils newPFObjFromLocation:location];
    location.objectId = newLocation.objectId;
    [newLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded) {
            PFQuery *query = [PFQuery queryWithClassName:@"Collection"];
            [query whereKey:@"objectId" equalTo:collection.objectId];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                if (error) {
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

- (void) postNewCollection:(Collection *)collection {
    PFObject *newCollection = [ParseUtils newPFObjFromCollection:collection];
    [newCollection saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded) {
            collection.createdAt = newCollection.createdAt;
            collection.objectId = newCollection.objectId;
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
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            [self.delegate generalRequestFail:error];
        } else {
            for(PFObject *obj in objects) {
                [ParseUtils collectionFromPFObj:obj completion:^(Collection * _Nonnull collection, NSError * _Nonnull) {
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
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            [self.delegate generalRequestFail:error];
        } else {
            for(PFObject *obj in objects) {
                [self.delegate addFetchedLocation:[ParseUtils locationFromPFObj:obj]];
            }
        }
    }];
}

- (void) fetchSavedLocationsByCollection:(Collection *)collection {
    // TODO: Implement
}

@end
