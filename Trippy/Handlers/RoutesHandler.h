//
//  RoutesHandler.h
//  Trippy
//
//  Created by Catherine Lu on 7/20/22.
//

#import <Foundation/Foundation.h>
@class Itinerary;

NS_ASSUME_NONNULL_BEGIN

@interface RoutesHandler : NSObject
- (instancetype)initWithMatrix:(NSDictionary *)matrix;
- (void)calculateRoutes:(Itinerary *)itinerary completion:(void (^)(NSArray *routes, NSError *))completion;
@end

NS_ASSUME_NONNULL_END
