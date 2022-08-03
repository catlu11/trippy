//
//  APIManager.m
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import "MapsAPIManager.h"

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

- (void)getUserAddressWithCompletion:(CLLocationCoordinate2D)coordinate completion:(void (^)(GMSAddress *response, NSError *))completion {
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:coordinate completionHandler:^(GMSReverseGeocodeResponse * _Nullable response, NSError * _Nullable error) {
        if (response) {
            completion(response.firstResult, nil);
        } else {
            completion(nil, error);
        }
    }];
}

@end
