//
//  ItineraryDetailViewController.h
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "LocationCollection.h"
#import "Location.h"

NS_ASSUME_NONNULL_BEGIN

@interface ItineraryDetailViewController : UIViewController
@property (strong, nonatomic) LocationCollection *collection;
@property (strong, nonatomic) Location *originLoc;
@property (strong, nonatomic) NSString *itineraryName;
@end

NS_ASSUME_NONNULL_END
