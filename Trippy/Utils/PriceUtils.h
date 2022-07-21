//
//  PriceUtils.h
//  Trippy
//
//  Created by Catherine Lu on 7/21/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PriceUtils : NSObject
- (double)computeExpectedCost:(NSArray *)types priceLevel:(NSNumber *)priceLevel;
@end

NS_ASSUME_NONNULL_END
