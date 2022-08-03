//
//  YelpAPIManager.m
//  Trippy
//
//  Created by Catherine Lu on 8/3/22.
//

#import "YelpAPIManager.h"
#import "YelpBusiness.h"

static NSString * const baseURLString = @"https://api.yelp.com/v3/businesses/";

@implementation YelpAPIManager

+ (YelpAPIManager *)shared {
    static YelpAPIManager *_sharedManager = nil;
    
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

- (NSString *)getYelpKey {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    return [NSString stringWithFormat:@"Bearer %@", dict[@"YelpApiKey"]];
}

- (void)getBusinessSearchWithCompletion:(NSNumber *)latitude longitude:(NSNumber *)longitude completion:(void (^)(NSArray *results, NSError *))completion {
    NSDictionary *params = @{@"latitude":latitude, @"longitude": longitude, @"limit": @20};
    [self GET:@"search" parameters:params headers:@{@"Authorization": [self getYelpKey]} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableArray *businesses = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in responseObject[@"businesses"]) {
            [businesses addObject:[[YelpBusiness alloc] initWithDictionary:dict]];
        }
        completion(businesses, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Yelp API Error: %@", error.description);
        completion(nil, error);
    }];
}
@end
