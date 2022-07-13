//
//  RouteLeg.h
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import <Foundation/Foundation.h>
#import "RouteStep.h"

NS_ASSUME_NONNULL_BEGIN

@interface RouteLeg : NSObject
@property (strong, nonatomic) NSNumber *distanceVal; // in meters
@property (strong, nonatomic) NSNumber *durationVal; // in seconds
@property (assign, nonatomic) CLLocationCoordinate2D startCoord;
@property (assign, nonatomic) CLLocationCoordinate2D endCoord;
@property (strong, nonatomic) NSArray *routeSteps;
// TODO: via waypoint attribute

- (instancetype) initWithDictionary:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
