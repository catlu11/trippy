//
//  MapUtils.h
//  Trippy
//
//  Created by Catherine Lu on 7/6/22.
//

#import <Foundation/Foundation.h>
@import GoogleMaps;
@class Location;
@class LocationCollection;

NS_ASSUME_NONNULL_BEGIN

#define DEFAULT_ZOOM 16

@interface MapUtils : NSObject
+ (NSString *)getApiKey;
+ (UIImage *)getStaticMapImage:(CLLocationCoordinate2D)location width:(int)width height:(int)height;
+ (GMSCoordinateBounds *)latLngDictToBounds:(NSDictionary *)bounds firstKey:(NSString *)firstKey secondKey:(NSString *)secondKey;
+ (CLLocationCoordinate2D)latLngDictToCoordinate:(NSDictionary *)bounds key:(NSString *)key;
+ (NSString *)cleanHTMLString:(NSString *)str;
+ (NSString *)generateOptimizedDirectionsApiUrl:(LocationCollection *)collection
                             origin:(Location *)origin
                      omitWaypoints:(NSArray *)omitWaypoints
                      departureTime:(NSDate *)departureTime;
+ (NSString *)generateOrderedDirectionsApiUrl:(LocationCollection *)collection
                                waypointOrder:(NSArray *)waypointOrder
                                       origin:(Location *)origin
                                departureTime:(NSDate *)departureTime;
+ (NSString *)generateMatrixApiUrl:(LocationCollection *)collection
                            origin:(Location *)origin
                     departureTime:(NSDate *)departureTime;
+ (CLLocationCoordinate2D)getCenterOfBounds:(GMSCoordinateBounds *)bounds;
+ (double)getRadiusOfBounds:(GMSCoordinateBounds *)bounds;
+ (double)metersToMiles:(int)meters;
+ (int)milesToMeters:(double)miles;
@end

NS_ASSUME_NONNULL_END
