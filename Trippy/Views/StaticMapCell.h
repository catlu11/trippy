//
//  StaticMapCell.h
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import <UIKit/UIKit.h>
@class Itinerary;
@class Location;
@class LocationCollection;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ListType) {
    kCollection,
    kLocation,
    kItinerary
};

@interface StaticMapCell : UITableViewCell
@property (strong, nonatomic) LocationCollection *collection;
@property (strong, nonatomic) Location *location;
@property (strong, nonatomic) Itinerary *itinerary;
@property (assign, nonatomic) BOOL showCheckmark;
- (void) updateUIElements:(ListType)type;
@end

NS_ASSUME_NONNULL_END
