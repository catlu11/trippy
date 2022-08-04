//
//  TSPUtils.m
//  Trippy
//
//  Created by Catherine Lu on 7/19/22.
//

#import "TSPUtils.h"
#import "DateUtils.h"
#import "Itinerary.h"
#import "WaypointPreferences.h"

@implementation TSPUtils

+ (NSArray *)reorder:(NSArray *)elements order:(NSArray *)order {
    NSMutableArray *newList = [[NSMutableArray alloc] init];
    for (NSNumber *ix in order) {
        [newList addObject:[elements objectAtIndex:[ix intValue]]];
    }
    return newList;
}

+ (int)totalDistance:(NSArray *)order matrix:(NSDictionary *)matrix {
    int sum = 0;
    int firstIndex = [[order firstObject] intValue];
    NSNumber *initialWeight = matrix[@"rows"][0][@"elements"][firstIndex+1][@"distance"][@"value"];
    sum += [initialWeight intValue];
    for (int i=1; i < order.count; i++) {
        int current = [order[i] intValue];
        int previous = [order[i-1] intValue];
        NSArray *edges = matrix[@"rows"][previous+1][@"elements"];
        NSNumber *weight = edges[current+1][@"distance"][@"value"];
        sum += [weight intValue];
    }
    int lastIndex = [[order lastObject] intValue];
    NSNumber *finalWeight = matrix[@"rows"][lastIndex+1][@"elements"][0][@"distance"][@"value"];
    return sum + [finalWeight intValue];
}

+ (int)distanceFromOrigin:(int)waypointIndex matrix:(NSDictionary *)matrix {
    NSNumber *distance = matrix[@"rows"][0][@"elements"][waypointIndex+1][@"distance"][@"value"];
    return [distance intValue];
}

+ (int)totalDuration:(NSArray *)order matrix:(NSDictionary *)matrix preferences:(NSDictionary *)preferences {
    int sum = 0;
    int firstIndex = [[order firstObject] intValue];
    NSNumber *initialWeight = matrix[@"rows"][0][@"elements"][firstIndex+1][@"duration"][@"value"];
    WaypointPreferences *initialPrefs = [[WaypointPreferences alloc] initWithDictionary:preferences[@"preferences"][firstIndex]];
    sum += ([initialWeight intValue] + [initialPrefs.stayDurationInSeconds doubleValue]);
    for (int i=1; i < order.count; i++) {
        int current = [order[i] intValue];
        int previous = [order[i-1] intValue];
        NSArray *edges = matrix[@"rows"][previous+1][@"elements"];
        NSNumber *weight = edges[current+1][@"duration"][@"value"];
        WaypointPreferences *prefs = [[WaypointPreferences alloc] initWithDictionary:preferences[@"preferences"][current]];
        sum += ([weight intValue] + [prefs.stayDurationInSeconds intValue]);
    }
    int lastIndex = [[order lastObject] intValue];
    NSNumber *finalWeight = matrix[@"rows"][lastIndex+1][@"elements"][0][@"duration"][@"value"];
    return sum + [finalWeight intValue];
}

// brute force solution
+ (NSArray *)tspDistance:(NSDictionary *)matrix
               waypoints:(NSArray *)waypoints
               itinerary:(Itinerary *)itinerary
      satisfyTimeWindows:(BOOL)satisfyTimeWindows {
    NSArray *potentialOrders = [self permutations:waypoints];
    NSArray *bestOrder = nil;
    int bestDistance = -1;
    for (NSArray *order in potentialOrders) {
        int dist = [self totalDistance:order matrix:matrix];
        if (satisfyTimeWindows && ![self doesSatisfyTimeWindows:order matrix:matrix itinerary:itinerary]) {
            continue;
        }
        if (dist < bestDistance || bestDistance == -1) {
            bestOrder = order;
            bestDistance = dist;
        }
    }
    return bestOrder;
}

# pragma mark - Private

+ (NSArray *)permutations:(NSArray *)elements {
    if (elements.count <= 1) {
        return @[elements];
    }
    NSArray *subarray = [elements subarrayWithRange:NSMakeRange(1, elements.count-1)];
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (NSArray *res in [self permutations:subarray]) {
        for (int i = 0; i < elements.count; i++) {
            NSArray *firstHalf = [res subarrayWithRange:NSMakeRange(0, i)];
            NSArray *current = [elements subarrayWithRange:NSMakeRange(0, 1)];
            NSArray *secondHalf = [res subarrayWithRange:NSMakeRange(i, res.count-i)];
            NSArray *res = [[firstHalf arrayByAddingObjectsFromArray:current] arrayByAddingObjectsFromArray:secondHalf];
            [results addObjectsFromArray:@[res]];
        }
    }
    return results;
}

+ (BOOL)doesSatisfyTimeWindows:(NSArray *)order
                        matrix:(NSDictionary *)matrix
                     itinerary:(Itinerary *)itinerary {
    NSDate *cumTime = itinerary.departureTime;
    int firstIndex = [[order firstObject] intValue];
    NSNumber *initialWeight = matrix[@"rows"][0][@"elements"][firstIndex+1][@"duration"][@"value"];
    WaypointPreferences *initialPrefs = [itinerary getPreferenceByIndex:firstIndex];
    cumTime = [cumTime dateByAddingTimeInterval:[initialWeight intValue]];
    if (initialPrefs.preferredEtaStart != nil
        && ![DateUtils isTimeInRange:initialPrefs.preferredEtaStart end:initialPrefs.preferredEtaEnd time:cumTime]) {
        return NO;
    }
    cumTime = [cumTime dateByAddingTimeInterval:[initialPrefs.stayDurationInSeconds doubleValue]];
    for (int i=1; i < order.count; i++) {
        int current = [order[i] intValue];
        int previous = [order[i-1] intValue];
        NSArray *edges = matrix[@"rows"][previous+1][@"elements"];
        NSNumber *weight = edges[current+1][@"duration"][@"value"];
        WaypointPreferences *prefs = [itinerary getPreferenceByIndex:current];
        cumTime = [cumTime dateByAddingTimeInterval:[weight intValue]];
        if (prefs.preferredEtaStart != nil && ![DateUtils isTimeInRange:prefs.preferredEtaStart end:prefs.preferredEtaEnd time:cumTime]) {
            return NO;
        }
        cumTime = [cumTime dateByAddingTimeInterval:[prefs.stayDurationInSeconds doubleValue]];
    }
    return YES;
}

@end
