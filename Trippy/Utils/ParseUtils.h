//
//  ParseUtils.h
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import <Foundation/Foundation.h>
@class Location;
@class LocationCollection;
@class Itinerary;
@class PFObject;

NS_ASSUME_NONNULL_BEGIN

@interface ParseUtils : NSObject
+ (NSArray *)getCollectionKeys;
+ (NSArray *)getLocationKeys;
+ (NSArray *)getItineraryKeys;
+ (NSString *)getLoggedInUsername;
+ (void) itineraryFromPFObj:(PFObject *)obj completion:(void (^)(Itinerary *itinerary, NSError *))completion;
+ (PFObject *)pfObjFromItinerary:(Itinerary *)it;
@end

NS_ASSUME_NONNULL_END
