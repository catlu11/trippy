//
//  RouteCell.m
//  Trippy
//
//  Created by Catherine Lu on 7/20/22.
//

#import "RouteCell.h"
#import "RouteOption.h"
#import "MapUtils.h"

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
}

- (void)updateUIElements {
    switch (self.route.type) {
        case kDefaultOptimized:
            self.typeLabel.text = @"Default (time-optimal)";
            break;
        case kDistance:
            self.typeLabel.text = @"Distance-optimal";
            break;
        case kCost:
            self.typeLabel.text = @"Cost-optimal";
            break;
    }
    self.totalDistLabel.text = [NSString stringWithFormat:@"Total distance: %f", [[MapUtils metersToMiles:self.route.distance] doubleValue]];
    self.totalDurationLabel.text = [NSString stringWithFormat:@"Total duration: %f", self.route.time / 60.0];
    // TODO: Implement when omission and cost are available
    self.omittedLabel.text = @"Omitted waypoints: 0";
    self.estCostLabel.text = @"Estimated cost: -";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

@end
