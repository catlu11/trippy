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
@property (strong, nonatomic) NSString *distanceText;
@property (strong, nonatomic) NSNumber *distanceVal;
@property (strong, nonatomic) NSString *durationText;
@property (strong, nonatomic) NSNumber *durationVal;
@property (assign, nonatomic) CLLocationCoordinate2D startCoord;
@property (assign, nonatomic) CLLocationCoordinate2D endCoord;
@property (strong, nonatomic) NSArray *routeSteps;
// TODO: via waypoint attribute

- (instancetype) initWithDictionary:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
