//
//  PriceUtils.h
//  Trippy
//
//  Created by Catherine Lu on 7/21/22.
//

#import <Foundation/Foundation.h>
@class Itinerary;
@class Location;

NS_ASSUME_NONNULL_BEGIN

@interface PriceUtils : NSObject
+ (double)computeLocationCost:(Location *)loc;
+ (double)computeExpectedCost:(Location *)loc itinerary:(Itinerary *)itinerary;
+ (double)computeTotalCost:(Itinerary *)itinerary locations:(NSArray *)locations omitWaypoints:(NSArray *)omitWaypoints;
@end

NS_ASSUME_NONNULL_END
