//
//  ParseUtils.h
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@class Location;
@class LocationCollection;
@class Itinerary;
@class PFObject;
@class PFFileObject;

NS_ASSUME_NONNULL_BEGIN

@interface ParseUtils : NSObject
+ (NSArray *)getCollectionKeys;
+ (NSArray *)getLocationKeys;
+ (NSArray *)getItineraryKeys;
+ (NSString *)getLoggedInUsername;
+ (void) itineraryFromPFObj:(PFObject *)obj completion:(void (^)(Itinerary *itinerary, NSError *))completion;
+ (void)collectionFromPFObj:(PFObject *)obj completion:(void (^)(LocationCollection *collection, NSError *))completion;
+ (Location *)locationFromPFObj:(PFObject *)obj;
+ (PFFileObject *)pfFileFromDict:(NSDictionary *)dict name:(NSString *)name;
+ (PFFileObject *)pfFileFromImage:(UIImage *)img name:(NSString *)name;
+ (void)pfObjFromCollection:(LocationCollection *)collection completion:(void (^)(PFObject *obj, NSError *))completion;
+ (void)pfObjFromLocation:(Location *)loc completion:(void (^)(PFObject *obj, NSError *))completio;
+ (void)pfObjFromItinerary:(Itinerary *)it completion:(void (^)(PFObject *obj, NSError *))completio;
@end

NS_ASSUME_NONNULL_END
