//
//  Itinerary.m
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import "Itinerary.h"
#import "MapUtils.h"
#import "RouteLeg.h"

@interface Itinerary ()
@property (strong, nonatomic) NSDictionary *fullJson;
@property (strong, nonatomic) NSDictionary *routeJson;
@end

@implementation Itinerary

- (NSArray *)routeLegs {
    NSMutableArray *legs = [[NSMutableArray alloc] init];
    for (NSDictionary *leg in self.routeJson[@"legs"]) {
        [legs addObject:[[RouteLeg alloc] initWithDictionary:leg]];
    }
    return legs;
}

- (GMSCoordinateBounds *)bounds {
    return [MapUtils latLngDictToBounds:self.routeJson[@"bounds"] firstKey:@"northeast" secondKey:@"southwest"];
}

- (NSString *)overviewPolyline {
    return self.routeJson[@"overview_polyline"][@"points"];
}

- (NSString *)waypointOrder {
    return self.routeJson[@"waypoint_order"];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    
    if (self) {
        self.fullJson = dict;
        self.routeJson = dict[@"routes"][0];
    }
    
    return self;
}

- (NSDictionary *)toDictionary {
    return self.fullJson;
}

- (void)reinitialize:(NSDictionary *)dict {
    self.fullJson = dict;
    self.routeJson = dict[@"routes"][0];
}

- (void)replaceLegs:(NSArray *)indicesToReplace newLegs:(NSArray *)newLegs {
    NSMutableArray *legs = self.routeJson[@"legs"];
    for (NSNumber *ix in indicesToReplace) {
        RouteLeg *newLeg = [newLegs objectAtIndex:[ix intValue]];
        [legs setObject:[newLeg toDictionary] atIndexedSubscript:[ix intValue]];
    }
}

- (NSDate *)computeArrival:(int)waypointIndex {
    return nil;
}

- (NSDate *)computeDeparture:(int)waypointIndex {
    return nil;
}

@end
