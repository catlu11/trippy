//
//  Itinerary.m
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import "Itinerary.h"
#import "LocationCollection.h"
#import "Location.h"
#import "MapUtils.h"
#import "RouteLeg.h"
#import "RouteStep.h"
#import "WaypointPreferences.h"
#import "PriceUtils.h"

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

- (NSArray *)waypointOrder {
    return self.routeJson[@"waypoint_order"];
}

- (void)setWaypointOrder:(NSArray *)waypointOrder {
    NSMutableDictionary *fullCopy = [_fullJson mutableCopy];
    NSMutableDictionary *routeCopy = [_routeJson mutableCopy];
    routeCopy[@"waypoint_order"] = waypointOrder;
    fullCopy[@"routes"] = @[routeCopy];
    _fullJson = fullCopy;
    _routeJson = routeCopy;
}

- (NSNumber *)mileageConstraint {
    return _mileageConstraint ?: @0;
}

- (NSNumber *)budgetConstraint {
    return _budgetConstraint ?: @0;
}

- (instancetype)initWithDictionary:(NSDictionary *)routesJson
                          prefJson:(NSDictionary *)prefJson
                         departure:(NSDate *)departure
                 mileageConstraint:(NSNumber *)mileageConstraint
                  budgetConstraint:(NSNumber *)budgetConstraint
                  sourceCollection:(LocationCollection *)sourceCollection
                    originLocation:(Location *)originLocation
                              name:(NSString *)name
                       isFavorited:(BOOL)isFavorited {
    self = [super init];
    
    if (self) {
        self.fullJson = [NSDictionary dictionaryWithDictionary:routesJson];
        self.routeJson = self.fullJson[@"routes"][0];
        self.isFavorited = isFavorited;
        
        if (prefJson) {
            self.prefJson = [NSDictionary dictionaryWithDictionary:prefJson];
        }
        else {
            NSMutableArray *prefs = [[NSMutableArray alloc] init];
            for (Location *l in sourceCollection.locations) {
                WaypointPreferences *newPref = [[WaypointPreferences alloc] initWithAttributes:[NSNull null] preferredEtaEnd:[NSNull null] stayDuration:@0 budget:[NSNull null]];
                [prefs addObject:[newPref toDictionary]];
            }
            self.prefJson = @{@"preferences": prefs};
        }
        self.departureTime = departure;
        self.sourceCollection = sourceCollection;
        self.originLocation = originLocation;
        self.name = name;
        self.mileageConstraint = mileageConstraint;
        self.budgetConstraint = budgetConstraint;
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
           departure:(NSDate *)departure
   mileageConstraint:(NSNumber *)mileageConstraint
    budgetConstraint:(NSNumber *)budgetConstraint {
    self.fullJson = [NSDictionary dictionaryWithDictionary:routesJson];
    self.routeJson = self.fullJson[@"routes"][0];
    self.prefJson = [NSDictionary dictionaryWithDictionary:prefJson];
    self.departureTime = departure;
    self.mileageConstraint = mileageConstraint;
    self.budgetConstraint = budgetConstraint;
}

- (void)replaceLegs:(NSArray *)indicesToReplace newLegs:(NSArray *)newLegs {
    NSMutableArray *legs = self.routeJson[@"legs"];
    for (NSNumber *ix in indicesToReplace) {
        RouteLeg *newLeg = [newLegs objectAtIndex:[ix intValue]];
        [legs setObject:[newLeg toDictionary] atIndexedSubscript:[ix intValue]];
    }
}

- (NSArray *)getOrderedLocations {
    NSMutableArray *ordered = [[NSMutableArray alloc] init];
    for (NSNumber *ix in self.waypointOrder) {
        int i = [ix intValue];
        [ordered addObject:[self.sourceCollection.locations objectAtIndex:i]];
    }
    return ordered;
}

- (NSArray *)getOmittedLocations {
    NSMutableArray *omitted = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.sourceCollection.locations.count; i++) {
        if (![self.waypointOrder containsObject:@(i)]) {
            [omitted addObject:[self.sourceCollection.locations objectAtIndex:i]];
        }
    }
    return omitted;
}

- (NSArray *)getInstructions {
    NSMutableArray *instructions = [[NSMutableArray alloc] init];
    for (RouteLeg *leg in self.routeLegs) {
        NSMutableArray *legInstructions = [[NSMutableArray alloc] init];
        for (RouteStep *step in leg.routeSteps) {
            [legInstructions addObject:step.instruction];
        }
        [instructions addObject:legInstructions];
    }
    return instructions;
}

- (WaypointPreferences *)getPreferenceByLocation:(Location *)loc {
    NSArray *prefsArray = self.prefJson[@"preferences"];
    NSDictionary *json = [prefsArray objectAtIndex:[self.sourceCollection.locations indexOfObject:loc]];
    return [[WaypointPreferences alloc] initWithDictionary:json];
}

- (WaypointPreferences *)getPreferenceByIndex:(int)waypointIndex {
    NSArray *prefsArray = self.prefJson[@"preferences"];
    NSDictionary *json = [prefsArray objectAtIndex:waypointIndex];
    return [[WaypointPreferences alloc] initWithDictionary:json];
}

- (void)updatePreference:(Location *)location pref:(WaypointPreferences *)pref {
    NSMutableArray *prefsArray = [self.prefJson[@"preferences"] mutableCopy];
    [prefsArray setObject:[pref toDictionary] atIndexedSubscript:[self.sourceCollection.locations indexOfObject:location]];
    NSMutableDictionary *copy = [self.prefJson mutableCopy];
    copy[@"preferences"] = prefsArray;
    self.prefJson = copy;
}

- (NSDate *)computeArrival:(int)waypointIndex {
    NSDate *lastDeparture = (waypointIndex > 0) ? [self computeDeparture:waypointIndex-1] : self.departureTime;
    RouteLeg *leg = [self.routeLegs objectAtIndex:waypointIndex];
    int travelTime = [leg.durationVal intValue];
    return [lastDeparture dateByAddingTimeInterval:travelTime];
}

- (NSDate *)computeDeparture:(int)waypointIndex {
    NSDate *arrivalTime = [self computeArrival:waypointIndex];
    Location *loc = [[self getOrderedLocations] objectAtIndex:waypointIndex];
    WaypointPreferences *pref = [self getPreferenceByLocation:loc];
    return [arrivalTime dateByAddingTimeInterval:[pref.stayDurationInSeconds intValue]];
}

- (NSNumber *)getTotalDistance {
    int sum = 0;
    for (RouteLeg *leg in self.routeLegs) {
        sum += [leg.distanceVal intValue];
    }
    return @([MapUtils metersToMiles:sum]);
}

- (NSNumber *)getTotalCost:(BOOL)includeAll {
    NSArray *locs = includeAll ? self.sourceCollection.locations : [self getOrderedLocations];
    return @([PriceUtils computeTotalCost:self locations:locs omitWaypoints:@[]]);
}

- (NSNumber *)getRadius {
    return @([MapUtils getRadiusOfBounds:self.bounds] / 1000); // in km
}

- (CLLocationCoordinate2D)getCentroid {
    int count = 1;
    double lat = self.originLocation.coord.latitude;
    double lon = self.originLocation.coord.longitude;
    for (Location *loc in [self getOrderedLocations]) {
        lat += loc.coord.latitude;
        lon += loc.coord.longitude;
        count += 1;
    }
    return CLLocationCoordinate2DMake(lat / count, lon / count);
}

@end
