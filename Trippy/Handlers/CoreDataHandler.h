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
- (NSManagedObject *)saveLocation:(Location *)loc;
- (NSManagedObject *)saveCollection:(LocationCollection *)col;
- (NSManagedObject *)saveItinerary:(Itinerary *)it;
- (NSManagedObject *)getEntityById:(NSString *)entity parseObjectId:(NSString *)parseObjectId;
- (NSArray *)fetchLocations;
- (NSArray *)fetchCollections;
- (NSArray *)fetchItineraries;
- (void)updateItinerary:(Itinerary *)it;
- (void)updateCollection:(LocationCollection *)col;
- (NSArray *)fetchUnsyncedCollections;
- (NSArray *)fetchUnsyncedItineraries;
- (void)deleteUnsyncedItineraries;
- (void)deleteUnsyncedCollections;
@end

NS_ASSUME_NONNULL_END
