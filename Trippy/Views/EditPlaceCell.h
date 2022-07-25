//
//  EditPlaceCell.h
//  Trippy
//
//  Created by Catherine Lu on 7/14/22.
//

#import <UIKit/UIKit.h>
@class Location;

NS_ASSUME_NONNULL_BEGIN

@protocol EditPlaceCellDelegate
- (void)didTapArrow:(int)waypointIndex;
@end

@interface EditPlaceCell : UITableViewCell
@property (nonatomic, weak) id<EditPlaceCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *placeName;
@property (weak, nonatomic) IBOutlet UILabel *estArrivalLabel;
@property (weak, nonatomic) IBOutlet UILabel *estDepartLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrowLabel;
@property (assign, nonatomic) int waypointIndex;

- (void)updateUIElements:(NSString *)locName arrival:(NSDate * _Nullable)arrival departure:(NSDate * _Nullable)departure;
- (void)addArrowTapWithSelector:(id)sender didTapArrow:(nullable SEL)didTapArrow;
- (void)disableArrow;
@end

NS_ASSUME_NONNULL_END
