//
//  FetchSavedHandler.h
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "LocationCollection.h"
#import "Location.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CacheDataHandlerDelegate
- (void) addFetchedCollection:(LocationCollection *)collection;
- (void) addFetchedLocation:(Location *)location;
- (void) postedCollectionSuccess:(LocationCollection *)collection;
- (void) generalRequestFail:(NSError *)error;
@end

@interface CacheDataHandler : NSObject
@property (nonatomic, weak) id<CacheDataHandlerDelegate> delegate;
- (void) fetchSavedCollections;
- (void) fetchSavedLocations;
- (void) postNewLocation:(Location *)location collection:(LocationCollection *)collection;
- (void) postNewCollection:(LocationCollection *)collection;
@end

NS_ASSUME_NONNULL_END
