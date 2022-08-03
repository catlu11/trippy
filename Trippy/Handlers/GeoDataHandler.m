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

@interface GeoDataHandler ()
@property (atomic) int itineraryFetchCount;
@end

@implementation GeoDataHandler

- (void) fetchItinerariesByCoordinate:(CLLocationCoordinate2D)coord rangeInKm:(double)rangeInKm {
    if (![NetworkManager shared].isConnected) {
        return;
    }
    PFGeoPoint *geopoint = [[PFGeoPoint alloc] init];
    geopoint.latitude = coord.latitude;
    geopoint.longitude = coord.longitude;
    PFQuery *query = [PFQuery queryWithClassName:@"Itinerary"];
    [query whereKey:@"startCoord" nearGeoPoint:geopoint withinKilometers:rangeInKm];
    [query whereKey:@"createdBy" notEqualTo:[PFUser currentUser]];
    __weak GeoDataHandler *weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            __strong GeoDataHandler *strongSelf = weakSelf;
            [strongSelf.delegate generalRequestFail:error];
        } else {
            self.itineraryFetchCount = objects.count;
            if (objects.count == 0) {
                __strong GeoDataHandler *strongSelf = weakSelf;
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
