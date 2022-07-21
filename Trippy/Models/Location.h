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
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *placeId;
@property (strong, nonatomic) NSArray *types;
@property (strong, nonatomic) NSNumber *priceLevel;
@property (strong, nonatomic) NSString *parseObjectId; // nonnull when derived from Parse object

- (instancetype) initWithParams:(NSString *)title
                        snippet:(NSString *)snippet
                       latitude:(double)latitude
                      longitude:(double)longitude
                           user:(NSString *)user
                        placeId:(NSString *)placeId
                          types:(NSArray *)types
                     priceLevel:(NSNumber *)priceLevel
                  parseObjectId:(NSString *)parseObjectId;
- (instancetype) initWithPlace:(GMSPlace *)place user:(NSString *)user;
@end

NS_ASSUME_NONNULL_END
