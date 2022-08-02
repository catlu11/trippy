//
//  APIManager.h
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface MapsAPIManager : AFHTTPSessionManager
+ (MapsAPIManager *)shared;
- (instancetype)initWithBaseURL:(NSURL *)url;
- (void)setupLocationManager;
- (void)getDirectionsWithCompletion:(NSString *)url completion:(void (^)(NSDictionary *response, NSError *))completion;
- (void)getRouteMatrixWithCompletion:(NSString *)url completion:(void (^)(NSDictionary *response, NSError *))completion;
@end

NS_ASSUME_NONNULL_END
