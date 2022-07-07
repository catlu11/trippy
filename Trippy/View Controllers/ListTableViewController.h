//
//  ListTableViewController.h
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import <UIKit/UIKit.h>

enum ListType {kCollection, kLocation};

NS_ASSUME_NONNULL_BEGIN

@interface ListTableViewController : UIViewController
@property (assign, nonatomic) enum ListType *listType;
@end

NS_ASSUME_NONNULL_END
