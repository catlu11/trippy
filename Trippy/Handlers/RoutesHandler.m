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
@property (strong, nonatomic) NSMutableDictionary *routes;
//@property (strong, nonatomic) NSMutableDictionary *newRoutes;
@end

@implementation RoutesHandler

- (instancetype) initWithMatrix:(NSDictionary *)matrix {
    self = [super init];
    if (self) {
        self.matrix = matrix;
    }
    return self;
}

- (void)calculateDefaultRoute:(Itinerary *)itinerary
                omitWaypoints:(NSArray *)omitWaypoints
                   completion:(void (^)(RouteOption *response, NSError *))completion {
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
            option.metTimeWindows = [TSPUtils doesSatisfyTimeWindows:newOrder matrix:self.matrix preferences:[itinerary toPrefsDictionary] departureTime:itinerary.departureTime];
            option.waypoints = newOrder;
            option.omittedWaypoints = omitWaypoints;
            option.distance = [TSPUtils totalDistance:newOrder matrix:self.matrix];
            option.time = [TSPUtils totalDuration:newOrder matrix:self.matrix preferences:[itinerary toPrefsDictionary]];
            option.cost = [PriceUtils computeTotalCost:itinerary locations:itinerary.sourceCollection.locations omitWaypoints:omitWaypoints];
            completion(option, nil);
        }
        else {
            NSLog(@"Error: %@", error.description);
        }
    }];
}

- (void)calculateDistanceOptimalRoute:(Itinerary *)itinerary
                        omitWaypoints:(NSArray *)omitWaypoints
                           completion:(void (^)(RouteOption *response, NSError *))completion {
    BOOL withTimeWindows = YES;
    NSMutableArray *waypoints = [[NSMutableArray alloc] init];
    for (int i = 0; i < itinerary.sourceCollection.locations.count; i++) {
        if (![omitWaypoints containsObject:@(i)]) {
            [waypoints addObject:@(i)];
        }
    }
    NSArray *order = [TSPUtils tspDistance:self.matrix
                                 waypoints:waypoints
                               preferences:[itinerary toPrefsDictionary]
                             departureTime:itinerary.departureTime];
    if (!order) { // if time windows cannot be met
        order = [TSPUtils tspDistance:self.matrix
                            waypoints:waypoints
                          preferences:nil
                        departureTime:itinerary.departureTime];
        withTimeWindows = NO;
    }
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
            option.metTimeWindows = withTimeWindows;
            option.numOmitted = omitWaypoints.count;
            option.omittedWaypoints = omitWaypoints;
            option.distance = [TSPUtils totalDistance:order matrix:self.matrix];
            option.time = [TSPUtils totalDuration:order matrix:self.matrix preferences:[itinerary toPrefsDictionary]];
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
    if (budget > 0) {
        int count = 0;
        while (remainingCost > budget && count < sortedByCost.count) {
            Location *loc = [sortedByCost objectAtIndex:count];
            [omittedIndices addObject:@([itinerary.sourceCollection.locations indexOfObject:loc])];
            remainingCost -= [PriceUtils computeExpectedCost:loc itinerary:itinerary];
            count += 1;
        }
    }
    if (omittedIndices.count == itinerary.sourceCollection.locations.count) {
        completion(nil, nil);
    } else {
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
}

- (int)numConstraintsSatisfied:(RouteOption *)route itinerary:(Itinerary *)itinerary {
    int count = 0;
    if (!route) {
        return 0;
    }
    if ([itinerary.mileageConstraint doubleValue] > 0 && route.distance <= [itinerary.mileageConstraint doubleValue]) {
        count += 1;
    }
    if (route.metTimeWindows) {
        count += 1;
    }
    if ([itinerary.budgetConstraint doubleValue] > 0 && route.cost <= [itinerary.budgetConstraint doubleValue]) {
        count += 1;
    }
    return count;
}

- (NSArray *)compareForBestRoutes:(RouteOption *)route1 route2:(RouteOption *)route2 itinerary:(Itinerary *)itinerary returnOne:(BOOL)returnOne {
    int power1 = [self numConstraintsSatisfied:route1 itinerary:itinerary];
    int power2 = [self numConstraintsSatisfied:route2 itinerary:itinerary];
    NSMutableArray *finalOptions = [[NSMutableArray alloc] init];
    if (power1 == 3 || (power1 > power2)) {
        [finalOptions addObject:route1];
    } else if (power2 == 3 || (power2 > 0 && power1 == 0)) {
        [finalOptions addObject:route2];
    } else {
        if (returnOne) {
            (power1 > power2) ? [finalOptions addObject:route1] : [finalOptions addObject:route2];
        } else {
            [finalOptions addObject:route1];
            [finalOptions addObject:route2];
        }
    }
    return finalOptions;
}

- (void)synthesizeRoutes:(RouteOption *)costOption
          distanceOption:(RouteOption *)distanceOption
                defaultOption:(RouteOption *)defaultOption
                    itinerary:(Itinerary *)itinerary
              completion:(void (^)(NSArray *routes, NSError *))completion {
    if (!(costOption.type == kCost && distanceOption.type == kDistance && defaultOption.type == kDefaultOptimized)) {
        return;
    }
    int costPower = [self numConstraintsSatisfied:costOption itinerary:itinerary];
    if (costPower > 0 && costOption.omittedWaypoints.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __block NSMutableDictionary *newRoutes = [[NSMutableDictionary alloc] init];
            dispatch_group_t group = dispatch_group_create();
            dispatch_group_enter(group);
            [self calculateDistanceOptimalRoute:itinerary omitWaypoints:costOption.omittedWaypoints completion:^(RouteOption *response, NSError *) {
                if (response) {
                    [newRoutes setObject:response forKey:@"distance"];
                }
                dispatch_group_leave(group);
            }];
            dispatch_group_enter(group);
            [self calculateDefaultRoute:itinerary omitWaypoints:costOption.omittedWaypoints completion:^(RouteOption *response, NSError *) {
                if (response) {
                    [newRoutes setObject:response forKey:@"default"];
                }
                dispatch_group_leave(group);
            }];
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                NSArray *options = [self compareForBestRoutes:newRoutes[@"distance"] route2:newRoutes[@"default"] itinerary:itinerary returnOne:YES];
                for (RouteOption *o in options) {
                    o.type = kCost;
                }
                completion([options arrayByAddingObjectsFromArray:@[distanceOption, defaultOption]], nil);
            });
        });
    } else {
        completion([self compareForBestRoutes:distanceOption route2:defaultOption itinerary:itinerary returnOne:NO], nil);
    }
}

- (void)calculateRoutes:(Itinerary *)itinerary completion:(void (^)(NSArray *routes, NSError *))completion {
    self.routes = [[NSMutableDictionary alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);
        [self calculateCostOptimalRoute:itinerary completion:^(RouteOption *response, NSError *) {
            if (response) {
                [self.routes setObject:response forKey:@"cost"];
            }
            dispatch_group_leave(group);
        }];
        dispatch_group_enter(group);
        [self calculateDistanceOptimalRoute:itinerary omitWaypoints:@[] completion:^(RouteOption *response, NSError *) {
            if (response) {
                [self.routes setObject:response forKey:@"distance"];
            }
            dispatch_group_leave(group);
        }];
        dispatch_group_enter(group);
        [self calculateDefaultRoute:itinerary omitWaypoints:@[] completion:^(RouteOption *response, NSError *) {
            if (response) {
                [self.routes setObject:response forKey:@"default"];
            }
            dispatch_group_leave(group);
        }];
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            [self synthesizeRoutes:self.routes[@"cost"] distanceOption:self.routes[@"distance"] defaultOption:self.routes[@"default"] itinerary:itinerary completion:completion];
        });
    });
}

@end
