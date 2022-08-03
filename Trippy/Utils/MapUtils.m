//
//  MapUtils.m
//  Trippy
//
//  Created by Catherine Lu on 7/6/22.
//

#import "MapUtils.h"
#import "MapsAPIManager.h"
#import "DateUtils.h"
#import "TSPUtils.h"
#import "Location.h"
#import "LocationCollection.h"
@import GooglePlaces;
@import GoogleMaps;

#define STATIC_MAP_URL @"https://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=%d&size=%dx%d&key=%@"
#define DIRECTIONS_URL @"directions/json?origin=place_id:%@&destination=place_id:%@&departure_time=%d&mode=driving&waypoints=%@&key=%@"
#define MATRIX_URL @"distancematrix/json?origins=%@&destinations=%@&departure_time=%d&mode=driving&key=%@"
#define API_BUFFER_IN_SECONDS 10

@implementation MapUtils

+ (NSString *)getApiKey {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    return dict[@"GMapsKey"];
}

+ (UIImage *)getStaticMapImage:(CLLocationCoordinate2D)location width:(int)width height:(int)height {
    NSString *staticMapUrl = [NSString stringWithFormat:STATIC_MAP_URL, location.latitude, location.longitude, DEFAULT_ZOOM, 2*width, 2*height, [self getApiKey]];
    NSString *percentEncodedURLString = [[NSURL URLWithDataRepresentation:[staticMapUrl dataUsingEncoding:NSUTF8StringEncoding] relativeToURL:nil] relativeString];
    NSURL *mapUrl = [NSURL URLWithString:percentEncodedURLString];
    NSData *data = [NSData dataWithContentsOfURL:mapUrl];
    UIImage *image = [UIImage imageWithData:data];
    return image;
}

+ (NSString *)generateOptimizedDirectionsApiUrl:(LocationCollection *)collection
                                         origin:(Location *)origin
                                  omitWaypoints:(NSArray *)omitWaypoints
                                   departureTime:(NSDate *)departureTime {
    NSString *stops = @"optimize:true";
    int count = 0;
    for (Location *loc in collection.locations) {
        count += 1;
        if ([omitWaypoints containsObject:@(count-1)]) {
            continue;
        }
        stops = [stops stringByAppendingString:[NSString stringWithFormat:@"|place_id:%@", loc.placeId]];
    }
    NSString *baseUrl = [NSString stringWithFormat:DIRECTIONS_URL, origin.placeId, origin.placeId, [DateUtils aheadSecondsFrom1970:departureTime aheadBy:API_BUFFER_IN_SECONDS], stops, [self getApiKey]];
    NSString *percentEncodedURLString = [[NSURL URLWithDataRepresentation:[baseUrl dataUsingEncoding:NSUTF8StringEncoding] relativeToURL:nil] relativeString];
    return percentEncodedURLString;
}

+ (NSString *)generateOrderedDirectionsApiUrl:(LocationCollection *)collection
                                waypointOrder:(NSArray *)waypointOrder
                                       origin:(Location *)origin
                                departureTime:(NSDate *)departureTime {
    NSString *stops = @"optimize:false";
    int count = 0;
    for (Location *loc in [TSPUtils reorder:collection.locations order:waypointOrder]) {
        stops = [stops stringByAppendingString:[NSString stringWithFormat:@"|place_id:%@", loc.placeId]];
    }
    NSString *baseUrl = [NSString stringWithFormat:DIRECTIONS_URL, origin.placeId, origin.placeId, [DateUtils aheadSecondsFrom1970:departureTime aheadBy:API_BUFFER_IN_SECONDS], stops, [self getApiKey]];
    NSString *percentEncodedURLString = [[NSURL URLWithDataRepresentation:[baseUrl dataUsingEncoding:NSUTF8StringEncoding] relativeToURL:nil] relativeString];
    return percentEncodedURLString;
}


+ (NSString *)generateMatrixApiUrl:(LocationCollection *)collection
                                          origin:(Location *)origin
                                   departureTime:(NSDate *)departureTime {
    NSString *stops = [NSString stringWithFormat:@"place_id:%@|", origin.placeId];
    for (Location *loc in collection.locations) {
        stops = [stops stringByAppendingString:[NSString stringWithFormat:@"|place_id:%@", loc.placeId]];
    }
    NSString *baseUrl = [NSString stringWithFormat:MATRIX_URL, stops, stops, [DateUtils aheadSecondsFrom1970:departureTime aheadBy:API_BUFFER_IN_SECONDS], [self getApiKey]];
    NSString *percentEncodedURLString = [[NSURL URLWithDataRepresentation:[baseUrl dataUsingEncoding:NSUTF8StringEncoding] relativeToURL:nil] relativeString];
    return percentEncodedURLString;
}

+ (CLLocationCoordinate2D)latLngDictToCoordinate:(NSDictionary *)bounds key:(NSString *)key {
    NSNumber *swLat = bounds[key][@"lat"];
    NSNumber *swLng = bounds[key][@"lng"];
    return CLLocationCoordinate2DMake([swLat doubleValue], [swLng doubleValue]);
}

+ (GMSCoordinateBounds *)latLngDictToBounds:(NSDictionary *)bounds firstKey:(NSString *)firstKey secondKey:(NSString *)secondKey {
    return [[GMSCoordinateBounds alloc] initWithCoordinate:[self latLngDictToCoordinate:bounds key:firstKey] coordinate:[self latLngDictToCoordinate:bounds key:secondKey]];
}

+ (NSString *)cleanHTMLString:(NSString *)str {
    NSRange range = [str rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch];
    while (range.location != NSNotFound) {
        str = [str stringByReplacingCharactersInRange:range withString:@""];
        range = [str rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch];
    }
    return str;
}

+ (double)metersToMiles:(int)meters {
    double inMiles = meters / 1609.0;
    return inMiles;
}

+ (int)milesToMeters:(double)miles {
    double inMeters = miles * 1609.0;
    return inMeters;
}



@end
