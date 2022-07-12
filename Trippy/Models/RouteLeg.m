//
//  RouteLeg.m
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import "RouteLeg.h"

@implementation RouteLeg

- (instancetype) initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    
    if (self) {
        self.distanceText = dict[@"distance"][@"text"];
        self.distanceVal = dict[@"distance"][@"val"];
        self.durationText = dict[@"duration"][@"text"];
        self.durationVal = dict[@"duration"][@"val"];
        NSNumber *startLat = dict[@"start_location"][@"lat"];
        NSNumber *startLng = dict[@"start_location"][@"lng"];
        NSNumber *endLat = dict[@"end_location"][@"lat"];
        NSNumber *endLng = dict[@"end_location"][@"lng"];
        self.startCoord = CLLocationCoordinate2DMake([startLat doubleValue], [startLng doubleValue]);
        self.endCoord = CLLocationCoordinate2DMake([endLat doubleValue], [endLng doubleValue]);
        
        NSMutableArray *steps = [[NSMutableArray alloc] init];
        for (NSDictionary *step in dict[@"steps"]) {
            [steps addObject:[[RouteStep alloc] initWithDictionary:step]];
        }
        self.routeSteps = steps;
    }
    
    return self;
}

@end
