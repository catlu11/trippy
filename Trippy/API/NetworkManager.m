//
//  NetworkManager.m
//  Trippy
//
//  Created by Catherine Lu on 7/27/22.
//

#import "NetworkManager.h"
#import "Reachability.h"

@implementation NetworkManager

+ (NetworkManager *)shared {
    static NetworkManager *_sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}

- (void)beginNotifier {
    self.internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged)
                                                 name:kReachabilityChangedNotification
                                               object:self.internetReachable];
    [self.internetReachable startNotifier];
    self.isConnected = [self.internetReachable isReachable];
}

- (void)reachabilityChanged {
    self.isConnected = [self.internetReachable isReachable];
}

@end
