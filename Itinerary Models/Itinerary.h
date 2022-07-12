//
//  Itinerary.h
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import <Foundation/Foundation.h>
#import "Location.h"
#import "LocationCollection.h"

NS_ASSUME_NONNULL_BEGIN

@interface Itinerary : NSObject
// General attributes
@property NSString *name;
@property NSString *parseObjectId;
@property NSDate *createdAt;
@property NSString *userId;
// Itinerary-specific attributes
@property LocationCollection *sourceCollection;
@property Location *originLocation;
@property NSArray *itineraryItems;
@property NSArray *viaPoints;
@property NSArray *routeLegs;

+ (instancetype) initWithDictionary:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
