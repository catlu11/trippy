//
//  RouteCell.m
//  Trippy
//
//  Created by Catherine Lu on 7/20/22.
//

#import "RouteCell.h"
#import "RouteOption.h"
#import "MapUtils.h"
#import "DateUtils.h"

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
            self.typeLabel.text = @"Default (Google)";
            break;
        case kDistance:
            self.typeLabel.text = @"Distance-optimal";
            break;
        case kCost:
            self.typeLabel.text = @"Cost-optimal";
            break;
    }
    self.totalDistLabel.text = [NSString stringWithFormat:@"Total distance: %.2f miles", [MapUtils metersToMiles:self.route.distance]];
    TimeInHrMin time = [DateUtils secondsToHourMin:self.route.time];
    self.totalDurationLabel.text = [NSString stringWithFormat:@"Total duration: %dhr%dmin", time.hours, time.minutes];
    self.omittedLabel.text = [NSString stringWithFormat:@"Omitted waypoints: %d", self.route.numOmitted];
    self.estCostLabel.text = [NSString stringWithFormat:@"Estimated cost: %.2f", self.route.cost];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

@end
