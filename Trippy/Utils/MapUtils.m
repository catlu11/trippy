//
//  MapUtils.m
//  Trippy
//
//  Created by Catherine Lu on 7/6/22.
//

#import "MapUtils.h"
#import "DateUtils.h"
#import "Location.h"
#import "LocationCollection.h"
@import GooglePlaces;

#define STATIC_MAP_URL @"https://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=%d&size=%dx%d&key=%@"
#define DIRECTIONS_URL @"json?origin=place_id:%@&destination=place_id:%@&departure_time=%d&mode=walking&waypoints=%@&key=%@"

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

+ (NSString *)generateDirectionsApiUrl:(LocationCollection *)collection
                                          origin:(Location *)origin
                                        optimizeOrder:(BOOL)optimizeOrder
                                   departureTime:(NSDate *)departureTime {
    // TODO: Enable via waypoints instead of just stopovers
    NSString *stops = optimizeOrder ? @"optimize:true" : @"";
    for(Location *loc in collection.locations) {
        stops = [stops stringByAppendingString:[NSString stringWithFormat:@"|place_id:%@", loc.placeId]];
    }
    NSString *baseUrl = [NSString stringWithFormat:DIRECTIONS_URL, origin.placeId, origin.placeId, [DateUtils aheadSecondsFrom1970:departureTime], stops, [self getApiKey]];
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


@end
