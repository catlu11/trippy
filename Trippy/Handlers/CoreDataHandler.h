//
//  CoreDataHandler.h
//  Trippy
//
//  Created by Catherine Lu on 7/25/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CoreDataHandler : NSObject
+ (CoreDataHandler *)shared;
- (void)saveLocation;
@end

NS_ASSUME_NONNULL_END
