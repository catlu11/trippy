//
//  GeoDataHandler.m
//  Trippy
//
//  Created by Catherine Lu on 8/3/22.
//

#import "GeoDataHandler.h"
#import "ParseUtils.h"
#import "Parse/Parse.h"
#import "Location.h"
#import "LocationCollection.h"
#import "Itinerary.h"
#import "NetworkManager.h"

#define QUERY_LIMIT 20

@interface GeoDataHandler ()
@property (atomic) int itineraryFetchCount;
@property (atomic) BOOL isFetchingItineraryByCoordinate;
@end

@implementation GeoDataHandler

- (void) fetchItinerariesByCoordinate:(CLLocationCoordinate2D)coord rangeInKm:(double)rangeInKm {
    if (![NetworkManager shared].isConnected || self.isFetchingItineraryByCoordinate) {
        return;
    }
    self.isFetchingItineraryByCoordinate = YES;
    PFGeoPoint *geopoint = [[PFGeoPoint alloc] init];
    geopoint.latitude = coord.latitude;
    geopoint.longitude = coord.longitude;
    PFQuery *query = [PFQuery queryWithClassName:@"Itinerary"];
    [query setLimit:QUERY_LIMIT];
    [query whereKey:@"startCoord" nearGeoPoint:geopoint withinKilometers:rangeInKm];
    [query whereKey:@"createdBy" notEqualTo:[PFUser currentUser]];
    __weak GeoDataHandler *weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        __strong GeoDataHandler *strongSelf = weakSelf;
        if (error) {
            [strongSelf.delegate generalRequestFail:error];
        } else {
            strongSelf.itineraryFetchCount = objects.count;
            if (objects.count == 0) {
                [strongSelf.delegate didAddAll];
            }
            for(PFObject *obj in objects) {
                [ParseUtils itineraryFromPFObj:obj completion:^(Itinerary * _Nonnull itinerary, NSError * _Nonnull) {
                    __strong GeoDataHandler *strongSelf = weakSelf;
                    if(error) {
                        [strongSelf.delegate generalRequestFail:error];
                    } else {
                        itinerary.isOffline = NO;
                        [strongSelf.delegate addFetchedNearbyItinerary:itinerary];
                    }
                    [strongSelf decrementItineraryFetchCount];
                }];
            }
        }
        strongSelf.isFetchingItineraryByCoordinate = NO;
    }];
}

# pragma mark - Private

- (void)decrementItineraryFetchCount {
    self.itineraryFetchCount -= 1;
    if (self.itineraryFetchCount == 0) {
        [self.delegate didAddAll];
    }
}

@end
