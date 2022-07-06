//
//  Location.h
//  Trippy
//
//  Created by Catherine Lu on 7/6/22.
//

#import <Foundation/Foundation.h>
@import GooglePlaces;

NS_ASSUME_NONNULL_BEGIN

@interface Location : NSObject
@property (assign, nonatomic) CLLocationCoordinate2D coord;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *snippet;

- (instancetype) initWithParams:(NSString *)title snippet:(NSString *)snippet latitude:(double)latitude longitude:(double)longitude;
- (instancetype) initWithPlace:(GMSPlace *)place;
@end

NS_ASSUME_NONNULL_END
