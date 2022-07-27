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
#import "CoreDataHandler.h"
#import "NetworkManager.h"

@implementation CacheDataHandler

- (void) postNewLocation:(Location *)location collection:(LocationCollection *)collection {
    // TODO: Handle offline mode
    PFObject *newLocation = [ParseUtils pfObjFromLocation:location];
    location.parseObjectId = newLocation.objectId;
    __weak CacheDataHandler *weakSelf = self;
    [newLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded) {
            [[CoreDataHandler shared] saveNewLocation:location]; // post to local cache
            PFQuery *query = [PFQuery queryWithClassName:@"Collection"];
            [query whereKey:@"objectId" equalTo:collection.parseObjectId];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                if (error) {
                    __strong CacheDataHandler *strongSelf = weakSelf;
                    [strongSelf.delegate generalRequestFail:error];
                } else {
                    PFRelation *relation = [object relationForKey:@"locations"];
                    [relation addObject:newLocation];
                    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        __strong CacheDataHandler *strongSelf = weakSelf;
                        if (succeeded) {
                            [[CoreDataHandler shared] updateCollection:collection]; // update local cache
                            [strongSelf.delegate postedLocationSuccess:location];
                        } else {
                            [strongSelf.delegate generalRequestFail:error];
                        }
                    }];
                }
            }];
        }
    }];
}

- (void) postNewCollection:(LocationCollection *)collection {
    // TODO: Handle offline mode
    PFObject *newCollection = [ParseUtils pfObjFromCollection:collection];
    __weak CacheDataHandler *weakSelf = self;
    [newCollection saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            __strong CacheDataHandler *strongSelf = weakSelf;
            collection.createdAt = newCollection.createdAt;
            collection.parseObjectId = newCollection.objectId;
            collection.lastUpdated = collection.createdAt;
            [[CoreDataHandler shared] saveNewCollection:collection]; // post to local cache
            [strongSelf.delegate postedCollectionSuccess:collection];
        }
    }];
}

- (void) postNewItinerary:(Itinerary *)it {
    // TODO: Handle offline mode
    PFObject *newItinerary = [ParseUtils pfObjFromItinerary:it];
    __weak CacheDataHandler *weakSelf = self;
    [newItinerary saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            __strong CacheDataHandler *strongSelf = weakSelf;
            it.createdAt = newItinerary.createdAt;
            it.parseObjectId = newItinerary.objectId;
            it.userId = [PFUser currentUser].username;
            [[CoreDataHandler shared] saveNewItinerary:it]; // post to local cache
            [strongSelf.delegate postedItinerarySuccess:it];
        }
    }];
}

- (void) updateItinerary:(Itinerary *)it {
    // TODO: Handle offline mode
    PFObject *obj = [ParseUtils pfObjFromItinerary:it];
    obj[@"directionsJson"] = [ParseUtils pfFileFromDict:[it toRouteDictionary] name:@"directions"];
    obj[@"preferencesJson"] = [ParseUtils pfFileFromDict:[it toPrefsDictionary] name:@"preferences"];
    obj[@"departure"] = it.departureTime;
    obj[@"mileageConstraint"] = it.mileageConstraint;
    obj[@"budgetConstraint"] = it.budgetConstraint;
    obj[@"isFavorited"] = [NSNumber numberWithBool:it.isFavorited];
    obj[@"staticMap"] = [ParseUtils pfFileFromImage:it.staticMap name:@"img"];
    __weak CacheDataHandler *weakSelf = self;
    [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            __strong CacheDataHandler *strongSelf = weakSelf;
            [[CoreDataHandler shared] updateItinerary:it]; // update local cache
            [strongSelf.delegate updatedItinerarySuccess:it];
        }
    }];
}

- (void) fetchSavedItineraries {
    if (![NetworkManager shared].isConnected) {
        NSArray *its = [[CoreDataHandler shared] fetchItineraries];
        for (Itinerary *it in its) {
            it.isOffline = YES;
            [self.delegate addFetchedItinerary:it];
        }
    } else {
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
                [[CoreDataHandler shared] clearEntity:@"Itinerary"]; // clear local cache
                for(PFObject *obj in objects) {
                    [ParseUtils itineraryFromPFObj:obj completion:^(Itinerary * _Nonnull itinerary, NSError * _Nonnull) {
                        __strong CacheDataHandler *strongSelf = weakSelf;
                        if(error) {
                            [strongSelf.delegate generalRequestFail:error];
                        } else {
                            itinerary.isOffline = NO;
                            [[CoreDataHandler shared] saveNewItinerary:itinerary]; // save to local cache
                            [strongSelf.delegate addFetchedItinerary:itinerary];
                        }
                    }];
                }
            }
        }];
    }
}

- (void) fetchSavedCollections {
    if (![NetworkManager shared].isConnected) {
        NSArray *cols = [[CoreDataHandler shared] fetchCollections];
        for (LocationCollection *col in cols) {
            col.isOffline = YES;
            [self.delegate addFetchedCollection:col];
        }
    } else {
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
                [[CoreDataHandler shared] clearEntity:@"LocationCollection"]; // clear local cache
                for(PFObject *obj in objects) {
                    [ParseUtils collectionFromPFObj:obj completion:^(LocationCollection * _Nonnull collection, NSError * _Nonnull) {
                        __strong CacheDataHandler *strongSelf = weakSelf;
                        if(error) {
                            [strongSelf.delegate generalRequestFail:error];
                        } else {
                            collection.isOffline = NO;
                            [strongSelf.delegate addFetchedCollection:collection];
                            [[CoreDataHandler shared] saveNewCollection:collection]; // save to local cache
                        }
                    }];
                }
            }
        }];
    }
}

- (void) fetchSavedLocations {
    if (![NetworkManager shared].isConnected) {
        NSArray *locs = [[CoreDataHandler shared] fetchLocations];
        for (Location *loc in locs) {
            loc.isOffline = YES;
            [self.delegate addFetchedLocation:loc];
        }
    } else {
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
                [[CoreDataHandler shared] clearEntity:@"Location"];
                for(PFObject *obj in objects) {
                    Location *loc = [ParseUtils locationFromPFObj:obj];
                    loc.isOffline = NO;
                    [strongSelf.delegate addFetchedLocation:loc];
                    [[CoreDataHandler shared] saveNewLocation:loc];
                }
            }
        }];
    }
}

- (void) fetchSavedLocationsByCollection:(LocationCollection *)collection {
    // TODO: Implement
}

@end
