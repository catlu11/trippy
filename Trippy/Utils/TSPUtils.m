//
//  TSPUtils.m
//  Trippy
//
//  Created by Catherine Lu on 7/19/22.
//

#import "TSPUtils.h"
#import "Itinerary.h"

@implementation TSPUtils

+ (NSArray *)permutations:(NSArray *)elements {
    if (elements.count <= 1) {
        return @[elements];
    }
    NSArray *subarray = [elements subarrayWithRange:NSMakeRange(1, elements.count-1)];
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (NSArray *res in [self permutations:subarray]) {
        for (int i = 0; i < elements.count; i+=1) {
            NSArray *firstHalf = [res subarrayWithRange:NSMakeRange(0, i)];
            NSArray *current = [elements subarrayWithRange:NSMakeRange(0, 1)];
            NSArray *secondHalf = [res subarrayWithRange:NSMakeRange(i, res.count-i)];
            NSArray *res = [[firstHalf arrayByAddingObjectsFromArray:current] arrayByAddingObjectsFromArray:secondHalf];
            [results addObjectsFromArray:@[res]];
        }
    }
    return results;
}

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
    NSNumber *initialWeight = matrix[@"rows"][0][@"elements"][firstIndex][@"distance"][@"value"];
    sum += [initialWeight intValue];
    for (int i=1; i < order.count; i+=1) {
        int current = [order[i] intValue];
        int previous = [order[i-1] intValue];
        NSArray *edges = matrix[@"rows"][previous+1][@"elements"];
        NSNumber *weight = edges[current+1][@"distance"][@"value"];
        sum += [weight intValue];
    }
    int lastIndex = [[order lastObject] intValue];
    NSNumber *finalWeight = matrix[@"rows"][lastIndex][@"elements"][0][@"distance"][@"value"];
    return sum + [finalWeight intValue];
}

+ (int)totalDuration:(NSArray *)order matrix:(NSDictionary *)matrix {
    int sum = 0;
    int firstIndex = [[order firstObject] intValue];
    NSNumber *initialWeight = matrix[@"rows"][0][@"elements"][firstIndex][@"duration"][@"value"];
    sum += [initialWeight intValue];
    for (int i=1; i < order.count; i+=1) {
        int current = [order[i] intValue];
        int previous = [order[i-1] intValue];
        NSArray *edges = matrix[@"rows"][previous+1][@"elements"];
        NSNumber *weight = edges[current+1][@"duration"][@"value"];
        sum += [weight intValue];
    }
    int lastIndex = [[order lastObject] intValue];
    NSNumber *finalWeight = matrix[@"rows"][lastIndex][@"elements"][0][@"duration"][@"value"];
    return sum + [finalWeight intValue];
}

// brute force solution
+ (NSArray *)tspDistance:(NSDictionary *)matrix {
    NSArray *locations = matrix[@"origin_addresses"];
    int n = locations.count - 1;
    
    NSMutableArray *waypoints = [[NSMutableArray alloc] init];
    for (int i = 0; i < n; i+=1) {
        [waypoints addObject:[[NSNumber alloc] initWithInt:i]];
    }
    NSArray *potentialOrders = [self permutations:waypoints];
    NSArray *bestOrder = nil;
    int bestDistance = -1;
    for (NSArray *order in potentialOrders) {
        int dist = [self totalDistance:order matrix:matrix];
        if (dist < bestDistance || bestDistance == -1) {
            bestOrder = order;
            bestDistance = dist;
        }
    }
    return bestOrder;
}

@end
