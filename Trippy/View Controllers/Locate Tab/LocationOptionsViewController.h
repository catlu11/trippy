//
//  LocationOptionsViewController.h
//  Trippy
//
//  Created by Catherine Lu on 7/21/22.
//

#import <UIKit/UIKit.h>
@class Location;

NS_ASSUME_NONNULL_BEGIN

@protocol LocationOptionsDelegate
- (void)didSelectOptions:(NSString *)name desc:(NSString *)desc;
@end

@interface LocationOptionsViewController : UIViewController
@property (weak, nonatomic) id<LocationOptionsDelegate> delegate;
@property (strong, nonatomic) Location *loc;
@end

NS_ASSUME_NONNULL_END
