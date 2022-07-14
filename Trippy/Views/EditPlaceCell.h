//
//  EditPlaceCell.h
//  Trippy
//
//  Created by Catherine Lu on 7/14/22.
//

#import <UIKit/UIKit.h>
@class Location;

NS_ASSUME_NONNULL_BEGIN

@interface EditPlaceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *placeName;
@property (weak, nonatomic) IBOutlet UILabel *estArrivalLabel;
@property (weak, nonatomic) IBOutlet UILabel *estDepartLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrowLabel;

- (void) updateUIElements:(NSString *)locName arrival:(NSDate * _Nullable)arrival departure:(NSDate * _Nullable)departure;
- (void) addArrowTapWithSelector:(id)sender didTapArrow:(nullable SEL)didTapArrow;
@end

NS_ASSUME_NONNULL_END
