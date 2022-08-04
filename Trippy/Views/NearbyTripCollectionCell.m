//
//  NearbyTripCollectionCell.m
//  Trippy
//
//  Created by Catherine Lu on 8/3/22.
//

#import "NearbyTripCollectionCell.h"
#import "Itinerary.h"

#define CELL_SHADOW_OPACITY 0.25;
#define CELL_SHADOW_RADIUS 4;
#define CELL_CORNER_RADIUS 15;

@interface NearbyTripCollectionCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;
@end

@implementation NearbyTripCollectionCell

- (void)updateUI {
    self.contentView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.contentView.layer.shadowOpacity = CELL_SHADOW_OPACITY;
    self.contentView.layer.shadowRadius = CELL_SHADOW_RADIUS;
    
    self.mapImageView.clipsToBounds = YES;
    self.mapImageView.layer.cornerRadius = CELL_CORNER_RADIUS;
    self.mapImageView.image = self.it.staticMap;
    
    self.nameLabel.text = self.it.name;
    self.authorLabel.text = [NSString stringWithFormat:@"Created by: %@", self.it.userId];
}

@end
