//
//  Itinerary.m
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import "Itinerary.h"

@implementation Itinerary

- (instancetype) initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    
    if (self) {
        self.directionsJson = dict;
        self.bounds = dict[@"bounds"]; // Bounds of routes
        NSMutableArray *legs = [[NSMutableArray alloc] init];
        for (NSDictionary *leg in dict[@"legs"]) {
            [legs addObject:[[RouteLeg alloc] initWithDictionary:leg]];
        }
        self.routeLegs = legs;
        self.overviewPolyline = dict[@"overview_polyline"];
        self.waypointOrder = dict[@"waypoint_order"];
    }
    
    return self;
}

@end
