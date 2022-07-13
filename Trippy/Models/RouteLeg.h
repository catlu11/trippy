//
//  RouteLeg.h
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import <Foundation/Foundation.h>
@class RouteStep;
@import GoogleMaps;
NS_ASSUME_NONNULL_BEGIN

@interface RouteLeg : NSObject
@property (readonly) NSNumber *distanceVal; // in meters
@property (readonly) NSNumber *durationVal; // in seconds
@property (readonly) CLLocationCoordinate2D startCoord;
@property (readonly) CLLocationCoordinate2D endCoord;
@property (readonly) NSArray *routeSteps;

- (instancetype) initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *) toDictionary;
@end

NS_ASSUME_NONNULL_END
