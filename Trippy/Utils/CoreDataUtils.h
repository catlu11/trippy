//
//  CoreDataUtils.h
//  Trippy
//
//  Created by Catherine Lu on 7/26/22.
//

#import <Foundation/Foundation.h>
@class Location;
@class NSManagedObject;

NS_ASSUME_NONNULL_BEGIN

@interface CoreDataUtils : NSObject
+ (Location *)locationFromManagedObject:(NSManagedObject *)obj;
@end

NS_ASSUME_NONNULL_END
