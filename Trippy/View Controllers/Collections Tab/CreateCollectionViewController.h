//
//  CreateCollectionViewController.h
//  Trippy
//
//  Created by Catherine Lu on 7/8/22.
//

#import <UIKit/UIKit.h>
#import "MapItemListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CreateCollectionDelegate
- (void)createdNew:(LocationCollection *)col ;
@end

@interface CreateCollectionViewController : MapItemListViewController
@property (nonatomic, weak) id<CreateCollectionDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
