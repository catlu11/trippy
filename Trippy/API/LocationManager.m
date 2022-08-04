//
//  LocationManager.m
//  Trippy
//
//  Created by Catherine Lu on 8/3/22.
//

#import "LocationManager.h"
@import GoogleMaps;

@interface LocationManager () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation LocationManager

+ (LocationManager *)shared {
    static LocationManager *_sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager requestWhenInUseAuthorization];
        self.locationManager.distanceFilter = 50;
        [self.locationManager startUpdatingLocation];
        self.locationManager.delegate = self;
    }
    
    return self;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = locations.lastObject;
    if (location && ![location isEqual:self.currentLocation]) {
        self.currentLocation = location;
        [self.delegate didFetchLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    CLAccuracyAuthorization accuracy = manager.accuracyAuthorization;
    switch (accuracy) {
        case CLAccuracyAuthorizationFullAccuracy:
          NSLog(@"Location accuracy is precise.");
          break;
        case CLAccuracyAuthorizationReducedAccuracy:
          NSLog(@"Location accuracy is not precise.");
          break;
    }

    switch (status) {
        case kCLAuthorizationStatusRestricted:
          NSLog(@"Location access was restricted.");
          break;
        case kCLAuthorizationStatusDenied:
          NSLog(@"User denied access to location.");
          break;
        case kCLAuthorizationStatusNotDetermined:
          NSLog(@"Location status not determined.");
          break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
          NSLog(@"Location status is OK.");
          break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [manager stopUpdatingLocation];
    NSLog(@"Error: %@", error.localizedDescription);
}

@end
