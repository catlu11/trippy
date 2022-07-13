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
+ (void)collectionFromPFObj:(PFObject *)obj completion:(void (^)(LocationCollection *collection, NSError *))completion;
+ (Location *)locationFromPFObj:(PFObject *)obj;
+ (PFObject *)pfObjFromCollection:(LocationCollection *)collection;
+ (PFObject *)pfObjFromLocation:(Location *)loc;
+ (PFObject *)pfObjFromItinerary:(Itinerary *)it;
@end

NS_ASSUME_NONNULL_END
