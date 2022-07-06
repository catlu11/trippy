//
//  SelectableMap.h
//  Trippy
//
//  Created by Catherine Lu on 7/6/22.
//

#import <UIKit/UIKit.h>
#import "Location.h"

NS_ASSUME_NONNULL_BEGIN

@interface SelectableMap : UIView
- (void) initWithCenter:(Location *)location;
- (void) addMarker:(Location *)location;
@end

NS_ASSUME_NONNULL_END
