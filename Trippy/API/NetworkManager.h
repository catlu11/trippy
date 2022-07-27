//
//  NetworkManager.h
//  Trippy
//
//  Created by Catherine Lu on 7/27/22.
//

#import <Foundation/Foundation.h>
@class Reachability;

NS_ASSUME_NONNULL_BEGIN

@interface NetworkManager : NSObject
+ (NetworkManager *)shared;
@property(strong, nonatomic) Reachability *internetReachable;
@property(assign, nonatomic) BOOL isConnected;
- (void)beginNotifier;
@end

NS_ASSUME_NONNULL_END
