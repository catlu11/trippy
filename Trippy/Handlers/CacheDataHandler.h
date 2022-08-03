//
//  FetchSavedHandler.h
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import <Foundation/Foundation.h>
@class Location;
@class LocationCollection;
@class Itinerary;

NS_ASSUME_NONNULL_BEGIN

@protocol CacheDataHandlerDelegate
- (void)addFetchedCollection:(LocationCollection *)collection;
- (void)addFetchedLocation:(Location *)location;
- (void)addFetchedItinerary:(Itinerary *)itinerary;
- (void)didAddAll;
- (void)postedCollectionSuccess:(LocationCollection *)collection;
- (void)postedItinerarySuccess:(Itinerary *)itinerary;
- (void)postedLocationSuccess:(Location *)location;
- (void)updatedItinerarySuccess:(Itinerary *)itinerary;
- (void)generalRequestFail:(NSError *)error;
@end

@interface CacheDataHandler : NSObject
@property (nonatomic, weak) id<CacheDataHandlerDelegate> delegate;
@property (assign, nonatomic) BOOL isFetchingItineraries;
@property (assign, nonatomic) BOOL isFetchingCollections;
@property (assign, nonatomic) BOOL isFetchingLocations;
- (void)fetchSavedCollections;
- (void)fetchSavedLocations;
- (void)fetchSavedItineraries;
- (void)postNewLocation:(Location *)location collection:(LocationCollection *)collection;
- (void)postNewCollection:(LocationCollection *)collection;
- (void)postNewItinerary:(Itinerary *)it;
- (void)updateItinerary:(Itinerary *)it;
@end

NS_ASSUME_NONNULL_END
