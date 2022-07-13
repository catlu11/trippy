//
//  FetchSavedHandler.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "CacheDataHandler.h"
#import "ParseUtils.h"
#import "Parse/Parse.h"
#import "Location.h"
#import "LocationCollection.h"
#import "Itinerary.h"

@implementation CacheDataHandler

- (void) postNewLocation:(Location *)location collection:(LocationCollection *)collection {
    PFObject *newLocation = [ParseUtils newPFObjWithLocation:location];
    location.parseObjectId = newLocation.objectId;
    __weak CacheDataHandler *weakSelf = self;
    [newLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded) {
            PFQuery *query = [PFQuery queryWithClassName:@"Collection"];
            [query whereKey:@"objectId" equalTo:collection.parseObjectId];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                if (error) {
                    __strong CacheDataHandler *strongSelf = weakSelf;
                    [strongSelf.delegate generalRequestFail:error];
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
    __weak CacheDataHandler *weakSelf = self;
    [newCollection saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            __strong CacheDataHandler *strongSelf = weakSelf;
            collection.createdAt = newCollection.createdAt;
            collection.parseObjectId = newCollection.objectId;
            collection.lastUpdated = collection.createdAt;
            [strongSelf.delegate postedCollectionSuccess:collection];
        }
    }];
}

- (void) postNewItinerary:(Itinerary *)it {
    PFObject *newItinerary = [ParseUtils newPFObjFromItinerary:it];
    __weak CacheDataHandler *weakSelf = self;
    [newItinerary saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            __strong CacheDataHandler *strongSelf = weakSelf;
            it.createdAt = newItinerary.createdAt;
            it.parseObjectId = newItinerary.objectId;
            it.userId = [PFUser currentUser].username;
            [strongSelf.delegate postedItinerarySuccess:it];
        }
    }];
}

- (void) fetchSavedItineraries {
    PFQuery *query = [PFQuery queryWithClassName:@"Itinerary"];
    [query whereKey:@"createdBy" equalTo:[PFUser currentUser]];
    [query includeKeys:[ParseUtils getItineraryKeys]];
    [query orderByDescending:@"createdAt"];
    
    __weak CacheDataHandler *weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            __strong CacheDataHandler *strongSelf = weakSelf;
            [strongSelf.delegate generalRequestFail:error];
        } else {
            for(PFObject *obj in objects) {
                [ParseUtils itineraryFromPFObj:obj completion:^(Itinerary * _Nonnull itinerary, NSError * _Nonnull) {
                    __strong CacheDataHandler *strongSelf = weakSelf;
                    if(error) {
                        [strongSelf.delegate generalRequestFail:error];
                    } else {
                        [strongSelf.delegate addFetchedItinerary:itinerary];
                    }
                }];
            }
        }
    }];
}

- (void) fetchSavedCollections {
    PFQuery *query = [PFQuery queryWithClassName:@"Collection"];
    [query whereKey:@"createdBy" equalTo:[PFUser currentUser]];
    [query includeKeys:[ParseUtils getCollectionKeys]];
    [query orderByDescending:@"updatedAt"];
    
    __weak CacheDataHandler *weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            __strong CacheDataHandler *strongSelf = weakSelf;
            [strongSelf.delegate generalRequestFail:error];
        } else {
            for(PFObject *obj in objects) {
                [ParseUtils collectionFromPFObj:obj completion:^(LocationCollection * _Nonnull collection, NSError * _Nonnull) {
                    __strong CacheDataHandler *strongSelf = weakSelf;
                    if(error) {
                        [strongSelf.delegate generalRequestFail:error];
                    } else {
                        [strongSelf.delegate addFetchedCollection:collection];
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
    
    __weak CacheDataHandler *weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        __strong CacheDataHandler *strongSelf = weakSelf;
        if (error) {
            [strongSelf.delegate generalRequestFail:error];
        } else {
            for(PFObject *obj in objects) {
                [strongSelf.delegate addFetchedLocation:[ParseUtils locationFromPFObj:obj]];
            }
        }
    }];
}

- (void) fetchSavedLocationsByCollection:(LocationCollection *)collection {
    // TODO: Implement
}

@end
