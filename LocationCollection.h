//
//  Collection.h
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import <Foundation/Foundation.h>
#import "Location.h"
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface LocationCollection : NSObject
@property (strong, nonatomic) NSArray *locations;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *parseObjectId;
@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSDate *lastUpdated;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *snippet;
@end

NS_ASSUME_NONNULL_END
