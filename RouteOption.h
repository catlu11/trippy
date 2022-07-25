//
//  RouteOption.h
//  Trippy
//
//  Created by Catherine Lu on 7/20/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RouteType) {
    kDefaultOptimized,
    kDistance,
    kCost
};

@interface RouteOption : NSObject
@property (assign, nonatomic) RouteType type;
@property (strong, nonatomic) NSDictionary *routeJson;
@property (strong, nonatomic) NSArray *waypoints;
@property int numOmitted;
@property int distance;
@property double cost;
@property double time;
@end

NS_ASSUME_NONNULL_END
