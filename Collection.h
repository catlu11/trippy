//
//  Collection.h
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import <Foundation/Foundation.h>
#import "Location.h"

NS_ASSUME_NONNULL_BEGIN

@interface Collection : NSObject
@property (strong, nonatomic) NSArray *locations;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *snippet;
@end

NS_ASSUME_NONNULL_END
