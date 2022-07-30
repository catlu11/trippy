//
//  RoutesHandler.m
//  Trippy
//
//  Created by Catherine Lu on 7/20/22.
//

#import "RoutesHandler.h"
#import "MapsAPIManager.h"
#import "Itinerary.h"
#import "LocationCollection.h"
#import "Location.h"
#import "RouteOption.h"
#import "TSPUtils.h"
#import "MapUtils.h"
#import "PriceUtils.h"

@interface RoutesHandler ()
@property (strong, nonatomic) NSDictionary *matrix;
@property (strong, nonatomic) NSMutableArray *routes;
@end

@implementation RoutesHandler

- (instancetype) initWithMatrix:(NSDictionary *)matrix {
    self = [super init];
    if (self) {
        self.matrix = matrix;
    }
    return self;
}

- (void)calculateDefaultRoute:(Itinerary *)itinerary omitWaypoints:(NSArray *)omitWaypoints completion:(void (^)(RouteOption *response, NSError *))completion {
    NSString *directionsUrl = [MapUtils generateOptimizedDirectionsApiUrl:itinerary.sourceCollection
                                                                 origin:itinerary.originLocation
                                                            omitWaypoints:omitWaypoints
                                                          departureTime:itinerary.departureTime];
    [[MapsAPIManager shared] getDirectionsWithCompletion:directionsUrl completion:^(NSDictionary *response, NSError *error) {
        if (response) {
            RouteOption *option = [[RouteOption alloc] init];
            option.type = kDefaultOptimized;
            option.routeJson = response;
            NSArray *newOrder = response[@"routes"][0][@"waypoint_order"];
            NSMutableArray *originalWaypoints = [[NSMutableArray alloc] init];
            for (int i = 0; i < itinerary.sourceCollection.locations.count; i++) {
                if (![omitWaypoints containsObject:@(i)]) {
                    [originalWaypoints addObject:@(i)];
                }
            }
            newOrder = [TSPUtils reorder:originalWaypoints order:newOrder];
            option.numOmitted = omitWaypoints.count;
            option.waypoints = newOrder;
            option.distance = [TSPUtils totalDistance:newOrder matrix:self.matrix];
            option.time = [TSPUtils totalDuration:newOrder matrix:self.matrix];
            option.cost = [PriceUtils computeTotalCost:itinerary locations:itinerary.sourceCollection.locations omitWaypoints:omitWaypoints];
            completion(option, nil);
        }
        else {
            NSLog(@"Error: %@", error.description);
        }
    }];
}

- (void)calculateDistanceOptimalRoute:(Itinerary *)itinerary completion:(void (^)(RouteOption *response, NSError *))completion {
    NSArray *order = [TSPUtils tspDistance:self.matrix];
    NSString *directionsUrl = [MapUtils generateOrderedDirectionsApiUrl:itinerary.sourceCollection
                                                          waypointOrder:order
                                                                 origin:itinerary.originLocation
                                                          departureTime:itinerary.departureTime];
    [[MapsAPIManager shared] getDirectionsWithCompletion:directionsUrl completion:^(NSDictionary *response, NSError *error) {
        if (response) {
            RouteOption *option = [[RouteOption alloc] init];
            option.type = kDistance;
            option.routeJson = response;
            option.waypoints = order;
            option.numOmitted = 0;
            option.distance = [TSPUtils totalDistance:order matrix:self.matrix];
            option.time = [TSPUtils totalDuration:order matrix:self.matrix];
            option.cost = [[itinerary getTotalCost:YES] doubleValue];
            completion(option, nil);
        } else {
            NSLog(@"Error: %@", error.description);
        }
    }];
}

// greedy algorithm to minimize number of omitted waypoints
- (void)calculateCostOptimalRoute:(Itinerary *)itinerary completion:(void (^)(RouteOption *response, NSError *))completion {
    NSArray *locations = itinerary.sourceCollection.locations;
    // sort locations by cost, descending
    NSArray *sortedByCost = [locations sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        Location *loc1 = obj1;
        Location *loc2 = obj2;
        double cost1 = [PriceUtils computeExpectedCost:loc1 itinerary:itinerary];
        double cost2 = [PriceUtils computeExpectedCost:loc2 itinerary:itinerary];
        if (cost1 > cost2) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        if (cost1 < cost2) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    // calculate omitted indices
    double remainingCost = [[itinerary getTotalCost:YES] doubleValue];
    double budget = [itinerary.budgetConstraint intValue];
    NSMutableArray *omittedIndices = [[NSMutableArray alloc] init];
    int count = 0;
    while (remainingCost > budget && count < sortedByCost.count) {
        Location *loc = [sortedByCost objectAtIndex:count];
        [omittedIndices addObject:@([itinerary.sourceCollection.locations indexOfObject:loc])];
        remainingCost -= [PriceUtils computeExpectedCost:loc itinerary:itinerary];
        count += 1;
    }
    // recompute route
    [self calculateDefaultRoute:itinerary omitWaypoints:omittedIndices completion:^(RouteOption *response, NSError *error) {
        if (response) {
            response.type = kCost;
            completion(response, nil);
        } else {
            completion(nil, error);
            NSLog(@"Error: %@", error.description);
        }
    }];
}

- (void)calculateRoutes:(Itinerary *)itinerary completion:(void (^)(NSArray *routes, NSError *))completion {
    self.routes = [[NSMutableArray alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);
        double currentDistance = [MapUtils milesToMeters:[[itinerary getTotalDistance] doubleValue]];
        if ([itinerary.mileageConstraint doubleValue] > 0 && currentDistance > [itinerary.mileageConstraint doubleValue]) {
            [self calculateDistanceOptimalRoute:itinerary completion:^(RouteOption *response, NSError *) {
                if (response) {
                    [self.routes addObject:response];
                }
                dispatch_group_leave(group);
            }];
        } else {
            dispatch_group_leave(group);
        }
        dispatch_group_enter(group);
        if ([itinerary.budgetConstraint doubleValue] > 0 && [[itinerary getTotalCost:YES] doubleValue] > [itinerary.budgetConstraint doubleValue]) {
            [self calculateCostOptimalRoute:itinerary completion:^(RouteOption *response, NSError *) {
                if (response) {
                    [self.routes addObject:response];
                }
                dispatch_group_leave(group);
            }];
        } else {
            dispatch_group_leave(group);
        }
        dispatch_group_enter(group);
        [self calculateDefaultRoute:itinerary omitWaypoints:@[] completion:^(RouteOption *response, NSError *) {
            if (response) {
                [self.routes addObject:response];
            }
            dispatch_group_leave(group);
        }];
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            completion(self.routes, nil);
        });
    });
}

@end
