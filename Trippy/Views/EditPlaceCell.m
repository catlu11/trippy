//
//  EditPlaceCell.m
//  Trippy
//
//  Created by Catherine Lu on 7/14/22.
//

#import "EditPlaceCell.h"

@implementation EditPlaceCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void) updateUIElements:(NSString *)locName arrival:(NSDate * _Nullable)arrival departure:(NSDate * _Nullable)departure {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"'T'HH:mm"];
    NSString *arrivalString = arrival ? [formatter stringFromDate:arrival] : @"-";
    NSString *departureString = departure ? [formatter stringFromDate:departure] : @"-";
    
    self.placeName.text = locName;
    self.estArrivalLabel.text = arrivalString;
    self.estDepartLabel.text = departureString;
    
    UITapGestureRecognizer *tapArrow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapArrow)];
    [self.arrowLabel addGestureRecognizer:tapArrow];
    [self.arrowLabel setUserInteractionEnabled:YES];
}

- (void) didTapArrow {
    [self.delegate didTapArrow:self.waypointIndex];
}

- (void) disableArrow {
    [self.arrowLabel setHidden:YES];
    [self.arrowLabel setUserInteractionEnabled:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
