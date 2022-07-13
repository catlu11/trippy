//
//  Collection.h
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import <Foundation/Foundation.h>
@class Location;
@class PFObject;

NS_ASSUME_NONNULL_BEGIN

@interface LocationCollection : NSObject
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *snippet;
@property (readonly) NSArray *locations;
@property (readonly) NSString *parseObjectId;
@property (readonly) NSDate *createdAt;

+ (void)initFromPFObj:(PFObject *)obj completion:(void (^)(LocationCollection *col, NSError *error))completion;
- (instancetype) initWithParams:(NSArray *)locations
                          title:(NSString*)title
                        snippet:(NSString*)snippet;
- (PFObject *)getPfObjRepresentation;
- (void)addLocation:(Location *)location;
- (void)removeLocation:(Location *)location;
@end

NS_ASSUME_NONNULL_END
