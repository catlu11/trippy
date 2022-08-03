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
- (void)updateUI;
@property (strong, nonatomic) YelpBusiness *business;
@end

NS_ASSUME_NONNULL_END
