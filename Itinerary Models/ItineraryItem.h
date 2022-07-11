//
//  ItineraryItem.h
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import <Foundation/Foundation.h>
#import "Location.h"

NS_ASSUME_NONNULL_BEGIN

@interface ItineraryItem : NSObject
@property NSString *parseObjectId;
@property Location *location;
// TODO: Preference attributes
@end

NS_ASSUME_NONNULL_END
