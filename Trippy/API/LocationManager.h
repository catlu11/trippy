//
//  LocationManager.h
//  Trippy
//
//  Created by Catherine Lu on 8/3/22.
//

#import <Foundation/Foundation.h>
@class CLLocation;

NS_ASSUME_NONNULL_BEGIN

@protocol LocationManagerDelegate
- (void)didFetchLocation;
@end

@interface LocationManager : NSObject
+ (LocationManager *)shared;
@property (weak, nonatomic) id<LocationManagerDelegate> delegate;
@property (strong, nonatomic) CLLocation * _Nullable currentLocation;
- (void)getUserLocation;
@end

NS_ASSUME_NONNULL_END