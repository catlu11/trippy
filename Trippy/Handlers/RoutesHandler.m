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
        double cost1 = [PriceUtils computeExpectedCost:loc1.types priceLevel:loc1.priceLevel];
        double cost2 = [PriceUtils computeExpectedCost:loc2.types priceLevel:loc2.priceLevel];
        if (cost1 > cost2) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if (cost1 < cost2) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    // calculate omitted indices
    double remainingCost = [[itinerary getTotalCost:YES] doubleValue];
    double budget = [itinerary.budgetConstraint intValue];
    NSMutableArray *omittedIndices = [[NSMutableArray alloc] init];
    int count = 0;
    while (remainingCost > budget) {
        Location *loc = [sortedByCost objectAtIndex:count];
        [omittedIndices addObject:@([itinerary.sourceCollection.locations indexOfObject:loc])];
        remainingCost -= [PriceUtils computeExpectedCost:loc.types priceLevel:loc.priceLevel];
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
    NSMutableArray *routes = [[NSMutableArray alloc] init];
    // TODO: Refactor to allow cost and distance routes to compute separately
    if (itinerary.mileageConstraint > 0) {
        [self calculateDistanceOptimalRoute:itinerary completion:^(RouteOption *response, NSError *) {
            [routes addObject:response];
            if (response.distance > [itinerary.mileageConstraint intValue]) {
                [self calculateDefaultRoute:itinerary omitWaypoints:@[] completion:^(RouteOption *response, NSError *) {
                    [routes addObject:response];
                    if ([itinerary.budgetConstraint doubleValue] > 0 && response.cost > [itinerary.budgetConstraint doubleValue]) {
                        [self calculateCostOptimalRoute:itinerary completion:^(RouteOption *response, NSError *) {
                            [routes addObject:response];
                            completion(routes, nil);
                        }];
                    } else {
                        completion(routes, nil);
                    }
                }];
            } else {
                completion(routes, nil);
            }
        }];
    }
}

@end
