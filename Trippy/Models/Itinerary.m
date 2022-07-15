//
//  Itinerary.m
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import "Itinerary.h"
#import "LocationCollection.h"
#import "MapUtils.h"
#import "RouteLeg.h"
#import "ItineraryPreferences.h"

@interface Itinerary ()
@property (strong, nonatomic) NSDictionary *fullJson;
@property (strong, nonatomic) NSDictionary *routeJson;
@property (strong, nonatomic) NSDictionary *prefJson;
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

- (instancetype)initWithDictionary:(NSDictionary *)routesJson
                          prefJson:(NSDictionary *)prefJson
                         departure:(NSDate *)departure
                  sourceCollection:(LocationCollection *)sourceCollection
                    originLocation:(Location *)originLocation name:(NSString *)name {
    self = [super init];
    
    if (self) {
        // creating a copy of dictionary data
        NSData *routeJsonData = [NSJSONSerialization dataWithJSONObject:routesJson options:0 error:nil];
        NSDictionary *routeDictCopy = [NSJSONSerialization JSONObjectWithData:routeJsonData options:kNilOptions error:nil];
        self.fullJson = routeDictCopy;
        self.routeJson = routeDictCopy[@"routes"][0];
        
        if (prefJson) {
            NSData *prefJsonData = [NSJSONSerialization dataWithJSONObject:prefJson options:0 error:nil];
            NSDictionary *prefDictCopy = [NSJSONSerialization JSONObjectWithData:prefJsonData options:kNilOptions error:nil];
            self.prefJson = prefDictCopy;
        }
        else {
            NSMutableArray *prefs = [[NSMutableArray alloc] init];
            for (Location *l in sourceCollection.locations) {
                ItineraryPreferences *newPref =  [[ItineraryPreferences alloc] initWithAttributes:[NSNull null] preferredTOD:[NSNull null] stayDuration:@0];
                [prefs addObject:[newPref toDictionary]];
            }
            self.prefJson = @{@"preferences": prefs};
        }
        self.departureTime = departure;
        self.sourceCollection = sourceCollection;
        self.originLocation = originLocation;
        self.name = name;
    }
    
    return self;
}

- (NSDictionary *)toRouteDictionary {
    return self.fullJson;
}

- (NSDictionary *)toPrefsDictionary {
    return self.prefJson;
}

- (void)reinitialize:(NSDictionary *)routesJson
            prefJson:(NSDictionary *)prefJson
           departure:(NSDate *)departure {
    // creating a copy of dictionary data
    NSData *routeJsonData = [NSJSONSerialization dataWithJSONObject:routesJson options:0 error:nil];
    NSDictionary *routeDictCopy = [NSJSONSerialization JSONObjectWithData:routeJsonData options:kNilOptions error:nil];
    NSData *prefJsonData = [NSJSONSerialization dataWithJSONObject:prefJson options:0 error:nil];
    NSDictionary *prefDictCopy = [NSJSONSerialization JSONObjectWithData:prefJsonData options:kNilOptions error:nil];
    
    self.fullJson = routeDictCopy;
    self.routeJson = routeDictCopy[@"routes"][0];
    self.prefJson = prefDictCopy;
    self.departureTime = departure;
}

- (void)replaceLegs:(NSArray *)indicesToReplace newLegs:(NSArray *)newLegs {
    NSMutableArray *legs = self.routeJson[@"legs"];
    for (NSNumber *ix in indicesToReplace) {
        RouteLeg *newLeg = [newLegs objectAtIndex:[ix intValue]];
        [legs setObject:[newLeg toDictionary] atIndexedSubscript:[ix intValue]];
    }
}

- (NSArray *)getOrderedLocations {
    NSMutableArray *ordered = [NSMutableArray arrayWithArray:self.sourceCollection.locations];
    for (NSNumber *ix in self.waypointOrder) {
        int i = [ix intValue];
        [ordered setObject:[self.sourceCollection.locations objectAtIndex:i] atIndexedSubscript:i];
    }
    return ordered;
}


- (ItineraryPreferences *)getPreference:(Location *)loc {
    NSArray *prefsArray = self.prefJson[@"preferences"];
    NSDictionary *json = [prefsArray objectAtIndex:[self.sourceCollection.locations indexOfObject:loc]];
    return [[ItineraryPreferences alloc] initWithDictionary:json];
}

- (void)updatePreference:(Location *)location pref:(ItineraryPreferences *)pref {
    NSMutableArray *prefsArray = [self.prefJson[@"preferences"] mutableCopy];
    [prefsArray setObject:[pref toDictionary] atIndexedSubscript:[self.sourceCollection.locations indexOfObject:location]];
    NSMutableDictionary *copy = [self.prefJson mutableCopy];
    copy[@"preferences"] = prefsArray;
    self.prefJson = copy;
}

- (NSDate *)computeArrival:(int)waypointIndex {
    // TODO: Implement
    return nil;
}

- (NSDate *)computeDeparture:(int)waypointIndex {
    // TODO: Implement
    return nil;
}

@end
