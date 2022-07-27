//
//  NetworkManager.m
//  Trippy
//
//  Created by Catherine Lu on 7/27/22.
//

#import "NetworkManager.h"

@implementation NetworkManager

+ (NetworkManager *)shared {
    static NetworkManager *_sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [AFNetworkReachabilityManager sharedManager];
        [_sharedManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    _sharedManager.isConnected = YES;
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    _sharedManager.isConnected = YES;
                    break;
                case AFNetworkReachabilityStatusUnknown:
                    _sharedManager.isConnected = NO;
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                    _sharedManager.isConnected = NO;
                    break;
                default:
                    break;
            }
        }];
        [_sharedManager startMonitoring];
    });

    return _sharedManager;
}

@end
