//
//  YelpAPIManager.h
//  Trippy
//
//  Created by Catherine Lu on 8/3/22.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface YelpAPIManager : AFHTTPSessionManager
+ (YelpAPIManager *)shared;
- (void)getBusinessSearchWithCompletion:(NSNumber *)latitude longitude:(NSNumber *)longitude;
@end

NS_ASSUME_NONNULL_END
