//
//  FetchSavedHandler.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "CacheDataHandler.h"
#import "ParseUtils.h"
#import "PriceUtils.h"
#import "MapUtils.h"
#import "Parse/Parse.h"
#import "Location.h"
#import "LocationCollection.h"
#import "Itinerary.h"
#import "CoreDataHandler.h"
#import "NetworkManager.h"
#import "CoreData/NSManagedObject.h"

@interface CacheDataHandler ()
@property (atomic) int itineraryFetchCount;
@property (atomic) int collectionFetchCount;
@property (atomic) int locationFetchCount;
@end

@implementation CacheDataHandler

- (void) postNewLocation:(Location *)location collection:(LocationCollection *)collection {
    // Offline mode not possible
    __weak CacheDataHandler *weakSelf = self;
    [ParseUtils pfObjFromLocation:location completion:^(PFObject * _Nonnull obj, NSError * _Nonnull) {
        PFObject *newLocation = obj;
        location.parseObjectId = newLocation.objectId;
        [newLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(succeeded) {
                [[CoreDataHandler shared] saveLocation:location]; // post to local cache
                PFQuery *query = [PFQuery queryWithClassName:@"Collection"];
                [query whereKey:@"objectId" equalTo:collection.parseObjectId];
                [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    __strong CacheDataHandler *strongSelf = weakSelf;
                    if (error) {
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
    }];
    
}

- (void) postNewCollection:(LocationCollection *)collection {
    if (![[NetworkManager shared] isConnected]) {
        [[CoreDataHandler shared] saveCollection:collection];
        collection.isOffline = YES;
        [self.delegate postedCollectionSuccess:collection];
    } else {
        __weak CacheDataHandler *weakSelf = self;
        [ParseUtils pfObjFromCollection:collection completion:^(PFObject * _Nonnull obj, NSError * _Nonnull) {
            PFObject *newCollection = obj;
            [newCollection saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    __strong CacheDataHandler *strongSelf = weakSelf;
                    collection.createdAt = newCollection.createdAt;
                    collection.parseObjectId = newCollection.objectId;
                    collection.lastUpdated = collection.createdAt;
                    [[CoreDataHandler shared] saveCollection:collection]; // post to local cache
                    [strongSelf.delegate postedCollectionSuccess:collection];
                }
            }];
        }];
    }
}

- (void) postNewItinerary:(Itinerary *)it {
    __weak CacheDataHandler *weakSelf = self;
    [ParseUtils pfObjFromItinerary:it completion:^(PFObject * _Nonnull obj, NSError * _Nonnull) {
        PFObject *newItinerary = obj;
        [newItinerary saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                __strong CacheDataHandler *strongSelf = weakSelf;
                it.createdAt = newItinerary.createdAt;
                it.parseObjectId = newItinerary.objectId;
                it.userId = [PFUser currentUser].username;
                [[CoreDataHandler shared] saveItinerary:it]; // post to local cache
                [strongSelf.delegate postedItinerarySuccess:it];
            }
        }];
    }];
}

- (void) updateItinerary:(Itinerary *)it {
    if (![[NetworkManager shared] isConnected]) {
        [[CoreDataHandler shared] updateItinerary:it];
        [self.delegate updatedItinerarySuccess:it];
    } else {
        __weak CacheDataHandler *weakSelf = self;
        [ParseUtils pfObjFromItinerary:it completion:^(PFObject * _Nonnull obj, NSError * _Nonnull) {
            obj[@"preferencesJson"] = [ParseUtils pfFileFromDict:[it toPrefsDictionary] name:@"preferences"];
            obj[@"departure"] = it.departureTime;
            obj[@"mileageConstraint"] = it.mileageConstraint;
            obj[@"budgetConstraint"] = it.budgetConstraint;
            obj[@"staticMap"] = [ParseUtils pfFileFromImage:it.staticMap name:@"img"];
            obj[@"directionsJson"] = [ParseUtils pfFileFromDict:[it toRouteDictionary] name:@"directions"];
            obj[@"isFavorited"] = [NSNumber numberWithBool:it.isFavorited];
            CLLocationCoordinate2D center = [it getCentroid];
            PFGeoPoint *coord = [[PFGeoPoint alloc] init];
            coord.latitude = center.latitude;
            coord.longitude = center.longitude;
            obj[@"startCoord"] = coord;
            obj[@"radius"] = @([MapUtils getRadiusOfBounds:it.bounds] / 1000);
            [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    __strong CacheDataHandler *strongSelf = weakSelf;
                    [[CoreDataHandler shared] updateItinerary:it]; // update local cache
                    [strongSelf.delegate updatedItinerarySuccess:it];
                }
            }];
        }];
    }
}

- (void) fetchSavedItineraries {
    if (self.isFetchingItineraries) {
        return;
    }
    
    self.isFetchingItineraries = YES;
    if (![NetworkManager shared].isConnected) {
        NSArray *its = [[CoreDataHandler shared] fetchItineraries];
        for (Itinerary *it in its) {
            it.isOffline = YES;
            [self.delegate addFetchedItinerary:it];
        }
        [self.delegate didAddAll];
        self.isFetchingItineraries = NO;
    } else {
        [[CoreDataHandler shared] clearEntity:@"Itinerary"]; // clear local cache
        PFQuery *query = [PFQuery queryWithClassName:@"Itinerary"];
        [query whereKey:@"createdBy" equalTo:[PFUser currentUser]];
        [query includeKeys:[ParseUtils getItineraryKeys]];
        [query orderByDescending:@"createdAt"];
        
        __weak CacheDataHandler *weakSelf = self;
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            __strong CacheDataHandler *strongSelf = weakSelf;
            if (error) {
                [strongSelf.delegate generalRequestFail:error];
            } else {
                strongSelf.itineraryFetchCount = objects.count;
                if (objects.count == 0) {
                    [strongSelf.delegate didAddAll];
                }
                for(PFObject *obj in objects) {
                    [ParseUtils itineraryFromPFObj:obj completion:^(Itinerary * _Nonnull itinerary, NSError * _Nonnull) {
                        __strong CacheDataHandler *strongSelf = weakSelf;
                        if(error) {
                            [strongSelf.delegate generalRequestFail:error];
                        } else {
                            itinerary.isOffline = NO;
                            if (itinerary.isFavorited) {
                                [[CoreDataHandler shared] saveItinerary:itinerary]; // save to local cache
                            }
                            [strongSelf.delegate addFetchedItinerary:itinerary];
                            [strongSelf decrementItineraryFetchCount];
                        }
                    }];
                }
                strongSelf.isFetchingItineraries = NO;
            }
        }];
    }
}

- (void) fetchSavedCollections:(BOOL)excludeDependents {
    if (self.isFetchingCollections) {
        return;
    }
    
    self.isFetchingCollections = YES;
    if (![NetworkManager shared].isConnected) {
        NSArray *cols = [[CoreDataHandler shared] fetchCollections];
        for (LocationCollection *col in cols) {
            col.isOffline = YES;
            [self.delegate addFetchedCollection:col];
        }
        [self.delegate didAddAll];
        self.isFetchingCollections = NO;
    } else {
        [[CoreDataHandler shared] clearEntity:@"LocationCollection"]; // clear local cache
        PFQuery *query = [PFQuery queryWithClassName:@"Collection"];
        [query whereKey:@"createdBy" equalTo:[PFUser currentUser]];
        [query includeKeys:[ParseUtils getCollectionKeys]];
        [query orderByDescending:@"updatedAt"];
        
        __weak CacheDataHandler *weakSelf = self;
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            __strong CacheDataHandler *strongSelf = weakSelf;
            if (error) {
                [strongSelf.delegate generalRequestFail:error];
            } else {
                strongSelf.collectionFetchCount = objects.count;
                if (objects.count == 0) {
                    [strongSelf.delegate didAddAll];
                }
                for(PFObject *obj in objects) {
                    [ParseUtils collectionFromPFObj:obj completion:^(LocationCollection * _Nonnull collection, NSError * _Nonnull) {
                        __strong CacheDataHandler *strongSelf = weakSelf;
                        if(error) {
                            [strongSelf.delegate generalRequestFail:error];
                        } else {
                            collection.isOffline = NO;
                            NSManagedObject *collectionMO = [[CoreDataHandler shared] saveCollection:collection]; // save to local cache
                            if (!excludeDependents || [[collectionMO valueForKey:@"dependents"] intValue] == 0) {
                                [strongSelf.delegate addFetchedCollection:collection];
                            }
                            [strongSelf decrementCollectionFetchCount];
                        }
                    }];
                }
                strongSelf.isFetchingCollections = NO;
            }
        }];
    }
}

- (void) fetchSavedLocations {
    if (self.isFetchingLocations) {
        return;
    }
    
    self.isFetchingLocations = YES;
    if (![NetworkManager shared].isConnected) {
        NSArray *locs = [[CoreDataHandler shared] fetchLocations];
        for (Location *loc in locs) {
            loc.isOffline = YES;
            [self.delegate addFetchedLocation:loc];
        }
        [self.delegate didAddAll];
        self.isFetchingLocations = NO;
    } else {
        [[CoreDataHandler shared] clearEntity:@"Location"];
        self.isFetchingLocations = YES;
        
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
                strongSelf.locationFetchCount = objects.count;
                if (objects.count == 0) {
                    [strongSelf.delegate didAddAll];
                }
                for(PFObject *obj in objects) {
                    Location *loc = [ParseUtils locationFromPFObj:obj];
                    loc.isOffline = NO;
                    [strongSelf.delegate addFetchedLocation:loc];
                    [[CoreDataHandler shared] saveLocation:loc];
                    [strongSelf decrementLocationFetchCount];
                }
                strongSelf.isFetchingLocations = NO;
            }
        }];
    }
}

# pragma mark - Private

- (void)decrementItineraryFetchCount {
    self.itineraryFetchCount -= 1;
    if (self.itineraryFetchCount == 0) {
        NSLog(@"fetched all itineraries");
        [self.delegate didAddAll];
    }
}

- (void)decrementCollectionFetchCount {
    self.collectionFetchCount -= 1;
    if (self.collectionFetchCount == 0) {
        NSLog(@"fetched all collections");
        [self.delegate didAddAll];
    }
}

- (void)decrementLocationFetchCount {
    self.locationFetchCount -= 1;
    if (self.locationFetchCount == 0) {
        NSLog(@"fetched all locations");
        [self.delegate didAddAll];
    }
}

@end
