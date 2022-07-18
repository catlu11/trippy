//
//  EditingItineraryViewController.h
//  Trippy
//
//  Created by Catherine Lu on 7/14/22.
//

#import <UIKit/UIKit.h>
@class Itinerary;

NS_ASSUME_NONNULL_BEGIN

@interface EditingItineraryViewController : UIViewController
@property (strong, nonatomic) Itinerary *baseItinerary;
@end

NS_ASSUME_NONNULL_END
