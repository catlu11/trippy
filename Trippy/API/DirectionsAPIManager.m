//
//  APIManager.m
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import "DirectionsAPIManager.h"
#import "MapUtils.h"
#import "Location.h"

static NSString * const baseURLString = @"https://maps.googleapis.com/maps/api/directions";

@implementation DirectionsAPIManager

+ (instancetype)shared {
    static DirectionsAPIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        sharedManager.requestSerializer = [AFJSONRequestSerializer serializer];
        [sharedManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    });
    return sharedManager;
}

- (void)getDirectionsWithCompletion:(NSDictionary *)params completion:(void (^)(NSDictionary *response, NSError *))completion {
    [self POST:baseURLString parameters:params headers:nil progress:nil
       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}
@end
