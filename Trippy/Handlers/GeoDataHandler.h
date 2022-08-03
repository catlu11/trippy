//
//  GeoDataHandler.h
//  Trippy
//
//  Created by Catherine Lu on 8/3/22.
//

#import <Foundation/Foundation.h>
@class Itinerary;
@import GoogleMaps;

NS_ASSUME_NONNULL_BEGIN

@protocol GeoDataHandlerDelegate
- (void)addFetchedNearbyItinerary:(Itinerary *)itinerary;
- (void)didAddAll;
- (void)generalRequestFail:(NSError *)error;
@end

@interface GeoDataHandler : NSObject
@property (nonatomic, weak) id<GeoDataHandlerDelegate> delegate;
- (void) fetchItinerariesByCoordinate:(CLLocationCoordinate2D)coord rangeInKm:(double)rangeInKm;
@end

NS_ASSUME_NONNULL_END
