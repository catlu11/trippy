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
- (void) generalRequestFail:(NSError *)error;
@end

@interface FetchSavedHandler : NSObject
@property (nonatomic, weak) id<FetchSavedHandlerDelegate> delegate;
- (void) fetchSavedCollections:(PFUser *)user;
@end

NS_ASSUME_NONNULL_END
