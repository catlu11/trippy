//
//  YelpBusinessCell.m
//  Trippy
//
//  Created by Catherine Lu on 8/3/22.
//

#import "YelpBusinessCell.h"
#import "YelpBusiness.h"

#define CELL_CORNER_RADIUS 15;
@interface YelpBusinessCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@end

@implementation YelpBusinessCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.previewImageView.layer.cornerRadius = CELL_CORNER_RADIUS;
}

- (void)updateUI {
    self.nameLabel.text = self.business.name;
    self.addressLabel.text = [NSString stringWithFormat:@"%@, %@", self.business.city, self.business.state];
    self.ratingLabel.text = [[self.business.rating stringValue] stringByAppendingString:@"★"];
    NSString *catString = @"";
    for (NSString *category in self.business.categories) {
        catString = [catString stringByAppendingString:category];
        catString = [catString stringByAppendingString:@", "];
    }
    self.categoriesLabel.text = [catString substringToIndex:catString.length-2];
    self.previewImageView.image = self.business.image;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
