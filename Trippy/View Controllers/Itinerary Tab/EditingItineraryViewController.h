//
//  EditingItineraryViewController.h
//  Trippy
//
//  Created by Catherine Lu on 7/14/22.
//

#import <UIKit/UIKit.h>
@class Itinerary;

NS_ASSUME_NONNULL_BEGIN
@protocol EditingItineraryDelegate
- (void) didSaveItinerary;
@end

@interface EditingItineraryViewController : UIViewController
@property (weak, nonatomic) id<EditingItineraryDelegate> delegate;
@property (strong, nonatomic) Itinerary *baseItinerary;
@end

NS_ASSUME_NONNULL_END
