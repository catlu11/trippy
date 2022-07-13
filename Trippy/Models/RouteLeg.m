//
//  RouteLeg.m
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import "RouteLeg.h"
#import "MapUtils.h"

@implementation RouteLeg

- (instancetype) initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    
    if (self) {
        self.distanceVal = dict[@"distance"][@"val"];
        self.durationVal = dict[@"duration"][@"val"];
        self.startCoord = [MapUtils latLngDictToCoordinate:dict key:@"start_location"];
        self.endCoord = [MapUtils latLngDictToCoordinate:dict key:@"end_location"];
        NSMutableArray *steps = [[NSMutableArray alloc] init];
        for (NSDictionary *step in dict[@"steps"]) {
            [steps addObject:[[RouteStep alloc] initWithDictionary:step]];
        }
        self.routeSteps = steps;
    }
    
    return self;
}

@end
