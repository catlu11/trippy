//
//  NearbyTripCollectionCell.h
//  Trippy
//
//  Created by Catherine Lu on 8/3/22.
//

#import <UIKit/UIKit.h>
@class Itinerary;

NS_ASSUME_NONNULL_BEGIN

@interface NearbyTripCollectionCell : UICollectionViewCell
@property (strong, nonatomic) Itinerary *itin;
- (void)updateUI;
@end

NS_ASSUME_NONNULL_END
