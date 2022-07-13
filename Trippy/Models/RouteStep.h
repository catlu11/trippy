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
@property (strong, nonatomic) NSNumber *distanceVal; // in meters
@property (strong, nonatomic) NSNumber *durationVal; // in seconds
@property (strong, nonatomic) NSString *instruction;
@property (assign, nonatomic) CLLocationCoordinate2D startCoord;
@property (assign, nonatomic) CLLocationCoordinate2D endCoord;
@property (strong, nonatomic) NSString *polyline;
@property (strong, nonatomic) NSString *travelMode;

- (instancetype) initWithDictionary:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
