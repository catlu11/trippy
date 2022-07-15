//
//  RouteLeg.m
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import "RouteLeg.h"
#import "RouteStep.h"
#import "MapUtils.h"

@interface RouteLeg ()
@property (strong, nonatomic) NSDictionary *json;
@end

@implementation RouteLeg

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

- (NSArray *)routeSteps {
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    for (NSDictionary *step in self.json[@"steps"]) {
        [steps addObject:[[RouteLeg alloc] initWithDictionary:step]];
    }
    return steps;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
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
