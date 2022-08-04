//
//  TSPUtils.h
//  Trippy
//
//  Created by Catherine Lu on 7/19/22.
//

#import <Foundation/Foundation.h>
@class Itinerary;

NS_ASSUME_NONNULL_BEGIN

@interface TSPUtils : NSObject
+ (NSArray *)tspDistance:(NSDictionary *)matrix
               waypoints:(NSArray *)waypoints
               itinerary:(Itinerary *)itinerary
      satisfyTimeWindows:(BOOL)satisfyTimeWindows;
+ (NSArray *)reorder:(NSArray *)elements order:(NSArray *)order;
+ (int)totalDistance:(NSArray *)order matrix:(NSDictionary *)matrix;
+ (int)totalDuration:(NSArray *)order matrix:(NSDictionary *)matrix preferences:(NSDictionary *)preferences;
+ (int)distanceFromOrigin:(NSNumber *)waypointIndex matrix:(NSDictionary *)matrix;
+ (BOOL)doesSatisfyTimeWindows:(NSArray *)order
                        matrix:(NSDictionary *)matrix
                     itinerary:(Itinerary *)itinerary;
@end

NS_ASSUME_NONNULL_END
