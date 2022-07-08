//
//  ParseUtils.h
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "Collection.h"
#import "Location.h"

NS_ASSUME_NONNULL_BEGIN


@interface ParseUtils : NSObject
+ (NSArray *)getCollectionKeys;
+ (NSArray *)getLocationKeys;
+ (NSString *)getLoggedInUserId;
+ (void) collectionFromPFObj:(PFObject *)obj completion:(void (^)(Collection *collection, NSError *))completion;
+ (Location *)locationFromPFObj:(PFObject *)obj;
+ (PFObject *)newPFObjFromCollection:(Collection *)collection;
+ (PFObject *)newPFObjFromLocation:(Location *)loc;
+ (PFObject *)oldPFObjFromLocation:(Location *)loc;
@end

NS_ASSUME_NONNULL_END
