//
//  PriceUtils.h
//  Trippy
//
//  Created by Catherine Lu on 7/21/22.
//

#import <Foundation/Foundation.h>
@class Itinerary;

NS_ASSUME_NONNULL_BEGIN

@interface PriceUtils : NSObject
+ (double)computeExpectedCost:(NSArray *)types priceLevel:(NSNumber *)priceLevel;
+ (double)computeTotalCost:(Itinerary *)itinerary locations:(NSArray *)locations omitWaypoints:(NSArray *)omitWaypoints;
@end

NS_ASSUME_NONNULL_END
