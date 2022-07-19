//
//  PreferencesViewController.h
//  Trippy
//
//  Created by Catherine Lu on 7/15/22.
//

#import <UIKit/UIKit.h>
@class WaypointPreferences;
@class Location;

NS_ASSUME_NONNULL_BEGIN

@protocol WaypointPreferencesDelegate
- (void) didUpdatePreference:(WaypointPreferences *)newPref location:(Location *)location;
@end

@interface WaypointPreferencesViewController : UIViewController
@property (weak, nonatomic) id<WaypointPreferencesDelegate> delegate;
@property (strong, nonatomic) WaypointPreferences *preferences;
@property (strong, nonatomic) Location *location;
@end

NS_ASSUME_NONNULL_END
