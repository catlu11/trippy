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
        NSDictionary *bounds = dict[@"routes"][0][@"bounds"]; // Bounds of routes
        NSNumber *neLat = bounds[@"northeast"][@"lat"];
        NSNumber *neLng = bounds[@"northeast"][@"lng"];
        NSNumber *swLat = bounds[@"southwest"][@"lat"];
        NSNumber *swLng = bounds[@"southwest"][@"lng"];
        self.bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:CLLocationCoordinate2DMake([neLat doubleValue], [neLng doubleValue]) coordinate:CLLocationCoordinate2DMake([swLat doubleValue], [swLng doubleValue])];
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
