//
//  ListTableViewController.h
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ListType) {
    kCollection,
    kLocation
};

@interface ListTableViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (assign, nonatomic) ListType listType;
@end

NS_ASSUME_NONNULL_END
