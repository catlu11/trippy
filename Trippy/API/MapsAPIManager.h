//
//  APIManager.h
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
@class CLLocation;
@class GMSAddress;

NS_ASSUME_NONNULL_BEGIN

@interface MapsAPIManager : AFHTTPSessionManager
+ (MapsAPIManager *)shared;
- (instancetype)initWithBaseURL:(NSURL *)url;
- (void)setupLocationManager;
- (void)getDirectionsWithCompletion:(NSString *)url completion:(void (^)(NSDictionary *response, NSError *))completion;
- (void)getRouteMatrixWithCompletion:(NSString *)url completion:(void (^)(NSDictionary *response, NSError *))completion;
- (void)getUserAddressWithCompletion:(void (^)(GMSAddress *response, NSError *))completion;
@property (strong, nonatomic) CLLocation * _Nullable currentLocation;
@end

NS_ASSUME_NONNULL_END
