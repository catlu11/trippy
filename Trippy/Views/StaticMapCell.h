//
//  StaticMapCell.h
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import <UIKit/UIKit.h>
#import "Collection.h"
#import "Location.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ListType) {
    kCollection,
    kLocation
};

@interface StaticMapCell : UITableViewCell
@property (strong, nonatomic) Collection *collection;
@property (strong, nonatomic) Location *location;
- (void) updateUIElements:(ListType)type;
@end

NS_ASSUME_NONNULL_END
