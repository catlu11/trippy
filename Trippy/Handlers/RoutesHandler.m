//
//  RoutesHandler.m
//  Trippy
//
//  Created by Catherine Lu on 7/20/22.
//

#import "RoutesHandler.h"
#import "MapsAPIManager.h"
#import "Itinerary.h"
#import "RouteOption.h"
#import "TSPUtils.h"
#import "MapUtils.h"

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

- (void)calculateDefaultRoute:(Itinerary *)itinerary completion:(void (^)(RouteOption *response, NSError *))completion {
    NSString *directionsUrl = [MapUtils generateOptimizedDirectionsApiUrl:itinerary.sourceCollection
                                                                 origin:itinerary.originLocation
                                                          departureTime:itinerary.departureTime];
    [[MapsAPIManager shared] getDirectionsWithCompletion:directionsUrl completion:^(NSDictionary * _Nonnull response, NSError * _Nonnull) {
        RouteOption *option = [[RouteOption alloc] init];
        option.type = kDefaultOptimized;
        option.routeJson = response;
        option.waypoints = response[@"routes"][0][@"waypointOrder"];
        option.distance = [TSPUtils totalDistance:response[@"routes"][0][@"waypointOrder"] matrix:self.matrix];
        option.time = [TSPUtils totalDuration:response[@"routes"][0][@"waypointOrder"] matrix:self.matrix];
        completion(option, nil);
    }];
}

- (void)calculateDistanceOptimalRoute:(Itinerary *)itinerary completion:(void (^)(RouteOption *response, NSError *))completion {
    NSArray *order = [TSPUtils tspDistance:self.matrix];
    NSString *directionsUrl = [MapUtils generateOrderedDirectionsApiUrl:itinerary.sourceCollection
                                                          waypointOrder:order
                                                                 origin:itinerary.originLocation
                                                          departureTime:itinerary.departureTime];
    [[MapsAPIManager shared] getDirectionsWithCompletion:directionsUrl completion:^(NSDictionary * _Nonnull response, NSError * _Nonnull) {
        RouteOption *option = [[RouteOption alloc] init];
        option.type = kDistance;
        option.routeJson = response;
        option.waypoints = order;
        option.distance = [TSPUtils totalDistance:order matrix:self.matrix];
        option.time = [TSPUtils totalDuration:order matrix:self.matrix];
        completion(option, nil);
    }];
}

- (RouteOption *)calculateCostOptimalRoute:(Itinerary *)itinerary {
    // TODO: Implement
    return nil;
}

- (void)calculateRoutes:(Itinerary *)itinerary completion:(void (^)(NSArray *routes, NSError *))completion {
    NSMutableArray *routes = [[NSMutableArray alloc] init];
    if (itinerary.mileageConstraint > 0) {
        [self calculateDistanceOptimalRoute:itinerary completion:^(RouteOption *response, NSError *) {
            [routes addObject:response];
            if (response.distance > [itinerary.mileageConstraint intValue]) {
                [self calculateDefaultRoute:itinerary completion:^(RouteOption *response, NSError *) {
                    [routes addObject:response];
                    completion(routes, nil);
                }];
            }
        }];
    }
}

@end
