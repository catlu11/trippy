//
//  RouteStep.m
//  Trippy
//
//  Created by Catherine Lu on 7/12/22.
//

#import "RouteStep.h"

@implementation RouteStep

- (instancetype) initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    
    if (self) {
        self.distanceText = dict[@"distance"][@"text"];
        self.distanceVal = dict[@"distance"][@"val"];
        self.durationText = dict[@"duration"][@"text"];
        self.durationVal = dict[@"duration"][@"val"];
        self.instruction = dict[@"html_instructions"];
        NSNumber *startLat = dict[@"start_location"][@"lat"];
        NSNumber *startLng = dict[@"start_location"][@"lng"];
        NSNumber *endLat = dict[@"end_location"][@"lat"];
        NSNumber *endLng = dict[@"end_location"][@"lng"];
        self.startCoord = CLLocationCoordinate2DMake([startLat doubleValue], [startLng doubleValue]);
        self.endCoord = CLLocationCoordinate2DMake([endLat doubleValue], [endLng doubleValue]);
        self.polyline = dict[@"polyline"];
        self.travelMode = dict[@"travel_mode"];
    }
    
    return self;
}
@end
