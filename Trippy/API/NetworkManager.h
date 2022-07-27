//
//  NetworkManager.h
//  Trippy
//
//  Created by Catherine Lu on 7/27/22.
//

#import <Foundation/Foundation.h>
#import "AFNetworkReachabilityManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetworkManager : AFNetworkReachabilityManager
+ (NetworkManager *)shared;
@property (assign, nonatomic) BOOL isConnected;
@end

NS_ASSUME_NONNULL_END
