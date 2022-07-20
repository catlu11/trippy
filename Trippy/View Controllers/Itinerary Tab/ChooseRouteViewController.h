//
//  ChooseRouteViewController.h
//  Trippy
//
//  Created by Catherine Lu on 7/20/22.
//

#import <UIKit/UIKit.h>
@class RouteOption;

NS_ASSUME_NONNULL_BEGIN

@protocol ChooseRouteDelegate
- (void)selectedRoute:(RouteOption *)route;
@end

@interface ChooseRouteViewController : UIViewController
@property (weak, nonatomic) id<ChooseRouteDelegate> delegate;
@property (strong, nonatomic) NSArray *routeOptions;
@end

NS_ASSUME_NONNULL_END
