//
//  Itinerary.h
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import <Foundation/Foundation.h>
#import "Location.h"
#import "Collection.h"

NS_ASSUME_NONNULL_BEGIN

@interface Itinerary : NSObject
@property NSString *name;
@property NSString *parseObjectId;
@property NSDate *createdAt;
@property NSString *userId;

@property LocationCollection *sourceCollection;
@property Location *originLocation;
@property NSArray *itineraryItems;
@property NSArray *viaPoints;
@property NSArray *routeLegs;
@end

NS_ASSUME_NONNULL_END
