//
//  ListTableViewController.h
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MapItemListViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (strong, nonatomic) NSMutableArray *data;
@property (assign, nonatomic) ListType listType;
@property (assign, nonatomic) BOOL *showSelection;
@end

NS_ASSUME_NONNULL_END
