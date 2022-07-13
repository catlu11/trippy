//
//  RouteStep.m
//  Trippy
//
//  Created by Catherine Lu on 7/12/22.
//

#import "RouteStep.h"
#import "MapUtils.h"

@interface RouteStep ()
@property (strong, nonatomic) NSDictionary *json;
@end

@implementation RouteStep

- (NSNumber *)distanceVal {
    return self.json[@"distance"][@"val"];
}

- (NSNumber *)durationVal {
    return self.json[@"duration"][@"val"];
}

- (CLLocationCoordinate2D)startCoord {
    return [MapUtils latLngDictToCoordinate:self.json key:@"start_location"];
}

- (CLLocationCoordinate2D)endCoord {
    return [MapUtils latLngDictToCoordinate:self.json key:@"end_location"];
}

- (NSString *)instruction {
    return self.json[@"html_instructions"];
}

- (NSString *)polyline {
    return self.json[@"polyline"];
}

- (NSString *)travelMode {
    return self.json[@"travel_mode"];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    
    if (self) {
        self.json = dict;
    }
    
    return self;
}

- (NSDictionary *)toDictionary {
    return self.json;
}

@end
