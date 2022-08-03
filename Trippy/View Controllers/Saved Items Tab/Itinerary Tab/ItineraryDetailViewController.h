//
//  ItineraryDetailViewController.h
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import <UIKit/UIKit.h>
@class Itinerary;

NS_ASSUME_NONNULL_BEGIN

@interface ItineraryDetailViewController : UIViewController
@property (strong, nonatomic) Itinerary *itinerary;
@property (assign, nonatomic) BOOL screenshotFlag;
- (void)disableEdit;
@end

NS_ASSUME_NONNULL_END
