//
//  APIManager.m
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import "MapsAPIManager.h"
#import "MapUtils.h"
#import "Location.h"

@interface MapsAPIManager () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) GMSPlacesClient *placesClient;
@end

static NSString * const baseURLString = @"https://maps.googleapis.com/maps/api/";

@implementation MapsAPIManager

+ (MapsAPIManager *)shared {
    static MapsAPIManager *_sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] initWithBaseURL:[NSURL URLWithString:baseURLString]];
    });

    return _sharedManager;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];

    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    return self;
}

- (void)setupLocationManager {
    // Initialize the location manager.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.distanceFilter = 50;
    [self.locationManager startUpdatingLocation];
    self.locationManager.delegate = self;

    self.placesClient = [GMSPlacesClient sharedClient];
}

- (void)getDirectionsWithCompletion:(NSString *)url completion:(void (^)(NSDictionary *response, NSError *))completion {
    [self POST:url parameters:nil headers:nil progress:nil
       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            completion(responseObject, nil);
        } else {
            NSLog(@"Bad directions API request");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)getRouteMatrixWithCompletion:(NSString *)url completion:(void (^)(NSDictionary *response, NSError *))completion {
    [self POST:url parameters:nil headers:nil progress:nil
       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            completion(responseObject, nil);
        } else {
            NSLog(@"Bad matrix API request");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)getUserAddress:(void (^)(GMSAddress *response, NSError *))completion {
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:self.currentLocation.coordinate completionHandler:^(GMSReverseGeocodeResponse * _Nullable response, NSError * _Nullable error) {
        if (response) {
            completion(response.firstResult, nil);
        } else {
            completion(nil, error);
        }
    }];
}

#pragma mark - CLLocationManagerDelegate

// Handle incoming location events.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
  CLLocation *location = locations.lastObject;
  self.currentLocation = location;
}

// Handle authorization for the location manager.
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  // Check accuracy authorization
  CLAccuracyAuthorization accuracy = manager.accuracyAuthorization;
  switch (accuracy) {
    case CLAccuracyAuthorizationFullAccuracy:
      NSLog(@"Location accuracy is precise.");
      break;
    case CLAccuracyAuthorizationReducedAccuracy:
      NSLog(@"Location accuracy is not precise.");
      break;
  }

  // Handle authorization status
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

// Handle location manager errors.
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  [manager stopUpdatingLocation];
  NSLog(@"Error: %@", error.localizedDescription);
}

@end
