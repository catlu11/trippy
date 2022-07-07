//
//  StaticMapCell.h
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import <UIKit/UIKit.h>
#import "Collection.h"

NS_ASSUME_NONNULL_BEGIN

@interface StaticMapCell : UITableViewCell
@property (strong, nonatomic) Collection *collection;
- (void) updateUIElements;
@end

NS_ASSUME_NONNULL_END
