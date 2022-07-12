//
//  APIManager.m
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import "DirectionsAPIManager.h"
#import "MapUtils.h"
#import "Location.h"

static NSString * const baseURLString = @"https://maps.googleapis.com/maps/api/directions/";

@implementation DirectionsAPIManager

+ (DirectionsAPIManager *)shared {
    static DirectionsAPIManager *_sharedManager = nil;
    
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
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}
@end
