//
//  YelpBusinessCell.h
//  Trippy
//
//  Created by Catherine Lu on 8/3/22.
//

#import <UIKit/UIKit.h>
@class YelpBusiness;

NS_ASSUME_NONNULL_BEGIN

@interface YelpBusinessCell : UITableViewCell
@property (strong, nonatomic) YelpBusiness *business;
- (void)updateUI;
@end

NS_ASSUME_NONNULL_END
