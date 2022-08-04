//
//  Itinerary.h
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import <Foundation/Foundation.h>
@class Location;
@class LocationCollection;
@class RouteLeg;
@class WaypointPreferences;

@import GoogleMaps;

NS_ASSUME_NONNULL_BEGIN

@interface Itinerary : NSObject

// Constant attributes
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) LocationCollection *sourceCollection;
@property (strong, nonatomic) Location *originLocation;

// Parse fields
@property (strong, nonatomic) NSString *parseObjectId;
@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSString *userId;

// Reassignable non-JSON
@property (strong, nonatomic) NSDate *departureTime;
@property (strong, nonatomic) NSNumber *mileageConstraint;
@property (strong, nonatomic) NSNumber *budgetConstraint;
@property (assign, nonatomic) BOOL isFavorited;

// JSON fields
@property (readonly) NSArray *routeLegs;
@property (readonly) GMSCoordinateBounds *bounds;
@property (readonly) NSString *overviewPolyline;
@property (strong, nonatomic) NSArray *waypointOrder;

// Offline caching
@property (strong, nonatomic) UIImage *staticMap;
@property (assign, nonatomic) BOOL isOffline;

- (instancetype)initWithDictionary:(NSDictionary *)routesJson
                          prefJson:(NSDictionary *)prefJson
                         departure:(NSDate *)departure
                 mileageConstraint:(NSNumber *)mileageConstraint
                  budgetConstraint:(NSNumber *)budgetConstraint
                  sourceCollection:(LocationCollection *)sourceCollection
                    originLocation:(Location *)originLocation
                              name:(NSString *)name
                       isFavorited:(BOOL)isFavorited;
- (void)reinitialize:(NSDictionary *)routesJson
            prefJson:(NSDictionary *)prefJson
           departure:(NSDate *)departure
   mileageConstraint:(NSNumber *)mileageConstraint
    budgetConstraint:(NSNumber *)budgetConstraint;

- (void)updatePreference:(Location *)location pref:(WaypointPreferences *)pref;
- (WaypointPreferences *)getPreferenceByLocation:(Location *)loc;
- (WaypointPreferences *)getPreferenceByIndex:(int)waypointIndex;
- (NSDictionary *)toRouteDictionary;
- (NSDictionary *)toPrefsDictionary;
- (NSArray *)getOrderedLocations;
- (NSArray *)getOmittedLocations;
- (NSArray *)getInstructions;
- (NSDate *)computeArrival:(int)waypointIndex;
- (NSDate *)computeDeparture:(int)waypointIndex;
- (NSNumber *)getTotalDistance;
- (NSNumber *)getTotalCost:(BOOL)includeAll;
@end

NS_ASSUME_NONNULL_END
