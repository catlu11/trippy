//
//  RouteCell.h
//  Trippy
//
//  Created by Catherine Lu on 7/20/22.
//

#import <UIKit/UIKit.h>
@class RouteOption;

NS_ASSUME_NONNULL_BEGIN

@interface RouteCell : UITableViewCell
@property (strong, nonatomic) RouteOption *route;
- (void)updateUIElements;
@end

NS_ASSUME_NONNULL_END
