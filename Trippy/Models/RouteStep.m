//
//  RouteStep.m
//  Trippy
//
//  Created by Catherine Lu on 7/12/22.
//

#import "RouteStep.h"
#import "MapUtils.h"

@implementation RouteStep

- (instancetype) initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    
    if (self) {
        self.distanceVal = dict[@"distance"][@"val"];
        self.durationVal = dict[@"duration"][@"val"];
        self.instruction = dict[@"html_instructions"];
        self.startCoord = [MapUtils latLngDictToCoordinate:dict key:@"start_location"];
        self.endCoord = [MapUtils latLngDictToCoordinate:dict key:@"end_location"];
        self.polyline = dict[@"polyline"];
        self.travelMode = dict[@"travel_mode"];
    }
    
    return self;
}
@end
