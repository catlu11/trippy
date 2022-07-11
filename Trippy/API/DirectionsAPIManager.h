//
//  APIManager.h
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@interface DirectionsAPIManager : AFHTTPSessionManager
+ (instancetype)shared;
@end

NS_ASSUME_NONNULL_END
