//
//  StaticMapCell.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "StaticMapCell.h"
#import "MapUtils.h"
#import "Location.h"

@interface StaticMapCell ()
@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;
@property (weak, nonatomic) IBOutlet UILabel *collectionNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@end

@implementation StaticMapCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void) updateUIElements {
    self.collectionNameLabel.text = self.collection.title;
    self.descriptionLabel.text = self.collection.snippet;
    [self.descriptionLabel sizeToFit];
    
    // Format date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM yyyy"];
    NSString *stringFromDate = [formatter stringFromDate:self.collection.lastUpdated];
    self.lastUpdateLabel.text = stringFromDate;
    
    // Get static thumbnail
    Location *firstLoc = self.collection.locations[0];
    self.mapImageView.image = [MapUtils getStaticMapImage:firstLoc.coord width:self.mapImageView.frame.size.width height:self.mapImageView.frame.size.height];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
