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
@class ItineraryPreferences;

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

// JSON fields
@property (readonly) NSArray *routeLegs;
@property (readonly) GMSCoordinateBounds *bounds;
@property (readonly) NSString *overviewPolyline;
@property (readonly) NSArray *waypointOrder;

- (instancetype)initWithDictionary:(NSDictionary *)routesJson
                          prefJson:(NSDictionary *)prefJson
                         departure:(NSDate *)departure
                  sourceCollection:(LocationCollection *)sourceCollection
                    originLocation:(Location *)originLocation
                              name:(NSString *)name;
- (void)reinitialize:(NSDictionary *)routesJson
            prefJson:(NSDictionary *)prefJson
           departure:(NSDate *)departure;
- (void)updatePreference:(Location *)location pref:(ItineraryPreferences *)pref;
- (ItineraryPreferences *)getPreference:(Location *)loc;
- (NSDictionary *)toRouteDictionary;
- (NSDictionary *)toPrefsDictionary;
- (NSArray *)getOrderedLocations;
- (NSDate *)computeArrival:(int)waypointIndex;
- (NSDate *)computeDeparture:(int)waypointIndex;
@end

NS_ASSUME_NONNULL_END
