//
//  Itinerary.m
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import "Itinerary.h"
#import "MapUtils.h"

@implementation Itinerary

- (instancetype) initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    
    if (self) {
        self.directionsJson = dict;
        self.bounds = [MapUtils latLngDictToBounds:dict[@"routes"][0][@"bounds"] firstKey:@"northeast" secondKey:@"southwest"];
        NSMutableArray *legs = [[NSMutableArray alloc] init];
        for (NSDictionary *leg in dict[@"routes"][0][@"legs"]) {
            [legs addObject:[[RouteLeg alloc] initWithDictionary:leg]];
        }
        self.routeLegs = legs;
        self.overviewPolyline = dict[@"routes"][0][@"overview_polyline"][@"points"];
        self.waypointOrder = dict[@"routes"][0][@"waypoint_order"];
    }
    
    return self;
}

@end
