//
//  CoreDataUtils.h
//  Trippy
//
//  Created by Catherine Lu on 7/26/22.
//

#import <Foundation/Foundation.h>
@class Location;
@class LocationCollection;
@class Itinerary;
@class NSManagedObject;

NS_ASSUME_NONNULL_BEGIN

@interface CoreDataUtils : NSObject
+ (Location *)locationFromManagedObject:(NSManagedObject *)obj;
+ (LocationCollection *)collectionFromManagedObject:(NSManagedObject *)obj;
+ (Itinerary *)itineraryFromManagedObject:(NSManagedObject *)obj;
+ (NSManagedObject *)managedObjectFromLocation:(Location *)loc;
+ (NSManagedObject *)managedObjectFromCollection:(LocationCollection *)col;
+ (NSManagedObject *)managedObjectFromItinerary:(Itinerary *)it;
@end

NS_ASSUME_NONNULL_END
