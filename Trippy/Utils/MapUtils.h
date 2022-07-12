//
//  MapUtils.h
//  Trippy
//
//  Created by Catherine Lu on 7/6/22.
//

#import <Foundation/Foundation.h>
@import GoogleMaps;
#import "Location.h"
#import "LocationCollection.h"

NS_ASSUME_NONNULL_BEGIN

#define DEFAULT_ZOOM 16

@interface MapUtils : NSObject
+ (NSString *)getApiKey;
+ (UIImage *)getStaticMapImage:(CLLocationCoordinate2D)location width:(int)width height:(int)height;
+ (NSString *)generateDirectionsApiUrl:(LocationCollection *)collection
                             origin:(Location *)origin
                           optimize:(BOOL)optimize
                      departureTime:(NSDate *)departureTime;
@end

NS_ASSUME_NONNULL_END
