//
//  ParseUtils.h
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "LocationCollection.h"
#import "Location.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParseUtils : NSObject
+ (NSArray *)getCollectionKeys;
+ (NSArray *)getLocationKeys;
+ (NSString *)getLoggedInUsername;
+ (void)collectionFromPFObj:(PFObject *)obj completion:(void (^)(LocationCollection *collection, NSError *))completion;
+ (Location *)locationFromPFObj:(PFObject *)obj;
+ (PFObject *)newPFObjWithCollection:(LocationCollection *)collection;
+ (PFObject *)newPFObjWithLocation:(Location *)loc;
+ (PFObject *)oldPFObjFromLocation:(Location *)loc;
@end

NS_ASSUME_NONNULL_END
