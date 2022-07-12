//
//  Itinerary.h
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import <Foundation/Foundation.h>
#import "Location.h"
#import "LocationCollection.h"
#import "RouteLeg.h"
@import GoogleMaps;

NS_ASSUME_NONNULL_BEGIN

@interface Itinerary : NSObject
// General attributes
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *parseObjectId;
@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSString *userId;

// Itinerary-specific attributes
@property (strong, nonatomic) LocationCollection *sourceCollection;
@property (strong, nonatomic) Location *originLocation;
@property (strong, nonatomic) NSDictionary *directionsJson;
@property (strong, nonatomic) NSDictionary *preferencesJson;

// JSON fields
@property (strong, nonatomic) NSArray *routeLegs;
@property (strong, nonatomic) GMSCoordinateBounds *bounds;
@property (strong, nonatomic) NSString *overviewPolyline;
@property (strong, nonatomic) NSArray *waypointOrder;

- (instancetype) initWithDictionary:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
