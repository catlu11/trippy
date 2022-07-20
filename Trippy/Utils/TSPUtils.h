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
+ (NSArray *)calculateRoutes:(Itinerary *)itinerary matrix:(NSDictionary *)matrix;
+ (NSArray *)tspDistance:(NSDictionary *)matrix;
+ (NSArray *)reorder:(NSArray *)elements order:(NSArray *)order;
@end

NS_ASSUME_NONNULL_END
