//
//  RouteCell.m
//  Trippy
//
//  Created by Catherine Lu on 7/20/22.
//

#import "RouteCell.h"

@interface RouteCell ()
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *omittedLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDistLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDurationLabel;
@property (weak, nonatomic) IBOutlet UILabel *estCostLabel;
@end

@implementation RouteCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
