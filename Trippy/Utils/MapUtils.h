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
+ (NSString *)generateDirectionsApiUrl:(LocationCollection *)collection
                             origin:(Location *)origin
                         optimizeOrder:(BOOL)optimizeOrder
                      departureTime:(NSDate *)departureTime;
+ (NSString *)generateMatrixApiUrl:(LocationCollection *)collection
                            origin:(Location *)origin
                     departureTime:(NSDate *)departureTime;
@end

NS_ASSUME_NONNULL_END
