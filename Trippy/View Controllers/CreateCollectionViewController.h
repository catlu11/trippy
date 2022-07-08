//
//  CreateCollectionViewController.h
//  Trippy
//
//  Created by Catherine Lu on 7/8/22.
//

#import <UIKit/UIKit.h>
#import "ListTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CreateCollectionDelegate
- (void) createdNew:(Collection *)col ;
@end

@interface CreateCollectionViewController : ListTableViewController
@property (nonatomic, weak) id<CreateCollectionDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
