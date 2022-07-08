//
//  FetchSavedHandler.h
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "Collection.h"
#import "Location.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FetchSavedHandlerDelegate
- (void) addFetchedCollection:(Collection *)collection;
- (void) addFetchedLocation:(Location *)location;
- (void) postedCollectionSuccess:(Collection *)collection;
- (void) generalRequestFail:(NSError *)error;
@end

@interface FetchSavedHandler : NSObject
@property (nonatomic, weak) id<FetchSavedHandlerDelegate> delegate;
- (void) fetchSavedCollections;
- (void) fetchSavedLocations;
- (void) postNewLocation:(Location *)location collection:(Collection *)collection;
- (void) postNewCollection:(Collection *)collection;
@end

NS_ASSUME_NONNULL_END
