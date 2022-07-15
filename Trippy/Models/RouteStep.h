//
//  RouteStep.h
//  Trippy
//
//  Created by Catherine Lu on 7/12/22.
//

#import <Foundation/Foundation.h>
@import GoogleMaps;

NS_ASSUME_NONNULL_BEGIN

@interface RouteStep : NSObject
@property (readonly) NSNumber *distanceVal; // in meters
@property (readonly) NSNumber *durationVal; // in seconds
@property (readonly) NSString *instruction;
@property (readonly) CLLocationCoordinate2D startCoord;
@property (readonly) CLLocationCoordinate2D endCoord;
@property (readonly) NSString *polyline;
@property (readonly) NSString *travelMode;

- (instancetype) initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *) toDictionary;
@end

NS_ASSUME_NONNULL_END
