//
//  MapUtils.m
//  Trippy
//
//  Created by Catherine Lu on 7/6/22.
//

#import "MapUtils.h"
#import "Location.h"
@import GoogleMaps;
@import GooglePlaces;

@implementation MapUtils

+ (UIImage *)getStaticMapImage:(CLLocationCoordinate2D)location width:(int)width height:(int)height {
    NSString *staticMapUrl = [NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?markers=color:blue|%@,%@&%@&sensor=true", location.latitude, location.longitude, [NSString stringWithFormat:@"zoom=%d&size=%dx%d", DEFAULT_ZOOM, 2*width, 2*height]];
    NSURL *mapUrl = [NSURL URLWithString:[staticMapUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
    UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:mapUrl]];
    return image;
}

@end
