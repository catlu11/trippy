//
//  CoreDataHandler.h
//  Trippy
//
//  Created by Catherine Lu on 7/25/22.
//

#import <Foundation/Foundation.h>
@class Location;
@class LocationCollection;
@class Itinerary;
@class NSManagedObject;

NS_ASSUME_NONNULL_BEGIN

@interface CoreDataHandler : NSObject
+ (CoreDataHandler *)shared;
- (void)clearEntity:(NSString *)entityName;
- (NSManagedObject *)saveNewLocation:(Location *)loc;
- (NSManagedObject *)saveNewCollection:(LocationCollection *)col;
- (NSManagedObject *)saveNewItinerary:(Itinerary *)it;
- (NSArray *)fetchLocations;
- (NSArray *)fetchCollections;
- (NSArray *)fetchItineraries;
- (NSManagedObject *)getEntityById:(NSString *)entity parseObjectId:(NSString *)parseObjectId;
@end

NS_ASSUME_NONNULL_END
