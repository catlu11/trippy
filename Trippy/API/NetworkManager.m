//
//  NetworkManager.m
//  Trippy
//
//  Created by Catherine Lu on 7/27/22.
//

#import "NetworkManager.h"
#import "Reachability.h"
#import "CoreDataHandler.h"
#import "CacheDataHandler.h"
#import "Itinerary.h"
#import "LocationCollection.h"

@interface NetworkManager ()
@property (strong, nonatomic) CacheDataHandler *parseHandler;
@end

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
    self.parseHandler = [[CacheDataHandler alloc] init];
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
    // sync objects created offline
    if (self.isConnected) {
        NSArray *unsyncedCollections = [[CoreDataHandler shared] fetchUnsyncedCollections];
        NSArray *unsyncedItineraries = [[CoreDataHandler shared] fetchUnsyncedItineraries];
        for (LocationCollection *col in unsyncedCollections) {
            if (!col.parseObjectId) {
                [self.parseHandler postNewCollection:col];
            }
        }
        for (Itinerary *it in unsyncedItineraries) {
            if (it.parseObjectId) {
                [self.parseHandler updateItinerary:it];
            } else {
                [self.parseHandler postNewItinerary:it];
            }
        }
        [[CoreDataHandler shared] deleteUnsyncedCollections];
        [[CoreDataHandler shared] deleteUnsyncedItineraries];
    }
}

@end
