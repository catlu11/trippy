//
//  ListTableViewController.h
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import <UIKit/UIKit.h>
#import "StaticMapCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ListTableViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (strong, nonatomic) NSMutableArray *data;
@property (assign, nonatomic) ListType listType;
@end

NS_ASSUME_NONNULL_END
