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
+ (NSString *)generateOptimizedDirectionsApiUrl:(LocationCollection *)collection
                             origin:(Location *)origin
                      departureTime:(NSDate *)departureTime;
+ (NSString *)generateOrderedDirectionsApiUrl:(LocationCollection *)collection
                                waypointOrder:(NSArray *)waypointOrder
                                       origin:(Location *)origin
                                departureTime:(NSDate *)departureTime;
+ (NSString *)generateMatrixApiUrl:(LocationCollection *)collection
                            origin:(Location *)origin
                     departureTime:(NSDate *)departureTime;
+ (NSNumber *)metersToMiles:(int)meters;
+ (NSNumber *)milesToMeters:(int)miles;
@end

NS_ASSUME_NONNULL_END
