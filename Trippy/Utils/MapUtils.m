//
//  MapUtils.m
//  Trippy
//
//  Created by Catherine Lu on 7/6/22.
//

#import "MapUtils.h"
#import "Location.h"
#import "LocationCollection.h"
@import GoogleMaps;
@import GooglePlaces;

#define STATIC_MAP_URL @"https://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=%d&size=%dx%d&key=%@"

@implementation MapUtils

+ (NSString *) getApiKey {
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

+ (NSDictionary *) generateRouteApiRequestParams:(LocationCollection *)collection
                                 optimize:(BOOL)optimize
                            departureTime:(NSDate *)departureTime
                              arrivalTime:(NSDate *)arrivalTime {
//    (Location *)origin
//                              waypoints:(NSArray *)waypoints
//                              stopovers:(NSArray *)stopovers
//                          departureTime:(NSDate *)departureTime
//                               optimize:(BOOL)optimize
    // TODO: Implement
}

@end
