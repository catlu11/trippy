//
//  PreferencesViewController.h
//  Trippy
//
//  Created by Catherine Lu on 7/19/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ItinerarySettingsDelegate
- (void) didUpdatePreference:(NSDate *)newDeparture newMileage:(NSNumber *)newMileage newBudget:(NSNumber *)newBudget;
@end

@interface ItinerarySettingsViewController : UIViewController
@property (weak, nonatomic) id<ItinerarySettingsDelegate> delegate;
@property (strong, nonatomic) NSDate *departure;
@property (strong, nonatomic) NSNumber *mileageConstraint;
@property (strong, nonatomic) NSNumber *budgetConstraint;
@property (strong, nonatomic) NSNumber *currentMileage;
@property (strong, nonatomic) NSNumber *currentBudget;
@end

NS_ASSUME_NONNULL_END
