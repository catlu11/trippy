//
//  NearbyTripCollectionCell.m
//  Trippy
//
//  Created by Catherine Lu on 8/3/22.
//

#import "NearbyTripCollectionCell.h"
#import "Itinerary.h"

@interface NearbyTripCollectionCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;
@end

@implementation NearbyTripCollectionCell

- (void)updateUI {
    self.contentView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.contentView.layer.shadowOpacity = 0.2;
    self.contentView.layer.shadowRadius = 4;
    
    self.mapImageView.clipsToBounds = YES;
    self.mapImageView.layer.cornerRadius = 15;
    self.mapImageView.image = self.it.staticMap;
    
    self.nameLabel.text = self.it.name;
    self.authorLabel.text = [NSString stringWithFormat:@"Created by: %@", self.it.userId];
}

@end
