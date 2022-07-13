//
//  Location.h
//  Trippy
//
//  Created by Catherine Lu on 7/6/22.
//

#import <Foundation/Foundation.h>
@import GooglePlaces;
@class PFObject;

NS_ASSUME_NONNULL_BEGIN

@interface Location : NSObject
@property (assign, nonatomic) CLLocationCoordinate2D coord;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *snippet;
@property (strong, nonatomic) NSString *placeId;
@property (readonly) NSString *parseObjectId;
@property (assign, nonatomic) BOOL *hasOrigin;

- (instancetype) initWithPFObj:(PFObject *)obj;
- (instancetype) initWithPlace:(GMSPlace *)place;
- (PFObject *)getPfObjRepresentation;
@end

NS_ASSUME_NONNULL_END
