//
//  PreferencesViewController.h
//  Trippy
//
//  Created by Catherine Lu on 7/15/22.
//

#import <UIKit/UIKit.h>
@class ItineraryPreferences;
@class Location;

NS_ASSUME_NONNULL_BEGIN

@protocol PreferencesDelegate
- (void) didUpdatePreference:(ItineraryPreferences *)newPref location:(Location *)location;
@end

@interface PreferencesViewController : UIViewController
@property (weak, nonatomic) id<PreferencesDelegate> delegate;
@property (strong, nonatomic) ItineraryPreferences *preferences;
@property (strong, nonatomic) Location *location;
@end

NS_ASSUME_NONNULL_END
