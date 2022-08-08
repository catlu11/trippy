//
//  StaticMapCell.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "StaticMapCell.h"
#import "MapUtils.h"
#import "Location.h"
#import "LocationCollection.h"
#import "Itinerary.h"
#import "CacheDataHandler.h"

@interface StaticMapCell ()
@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *starredImage;
@property (strong, nonatomic) CacheDataHandler *parseHandler;
@end

@implementation StaticMapCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.parseHandler = [[CacheDataHandler alloc] init];
}

- (void) updateUIElements:(ListType)type {
    switch (type) {
        case kCollection:
            [self updateUIElementsCollection];
            break;
        case kLocation:
            [self updateUIElementsLocation];
            break;
        case kItinerary:
            [self updateUIElementsItinerary];
            break;
    }
}

- (void) updateUIElementsItinerary {
    if (self.itinerary.isOffline) {
        self.backgroundColor = [UIColor systemGrayColor];
    } else {
        self.backgroundColor = [UIColor systemBackgroundColor];
    }
    
    [self.starredImage setHidden:NO];
    
    self.titleLabel.text = self.itinerary.name;
    self.descriptionLabel.text = [NSString stringWithFormat:@"Origin: %@\nSource: %@", self.itinerary.originLocation.title, self.itinerary.sourceCollection.title];
    [self.descriptionLabel sizeToFit];
    
    // Format date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM yyyy"];
    NSString *stringFromDate = [formatter stringFromDate:self.itinerary.createdAt];
    self.lastUpdateLabel.text = stringFromDate;
    
    // Get static thumbnail
    if(self.itinerary.sourceCollection.locations.count > 0) {
        Location *firstLoc = self.itinerary.sourceCollection.locations[0];
        self.mapImageView.image = firstLoc.staticMap;
    }
    else {
        self.mapImageView.image = [UIImage systemImageNamed:@"tray"];
    }
    
    self.starredImage.image = self.itinerary.isFavorited ? [UIImage systemImageNamed:@"star.fill"] : [UIImage systemImageNamed:@"star"];
    UITapGestureRecognizer *tapStar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapStar)];
    [self.starredImage addGestureRecognizer:tapStar];
    [self.starredImage setUserInteractionEnabled:YES];
}

- (void) didTapStar {
    self.itinerary.isFavorited = !self.itinerary.isFavorited;
    self.starredImage.image = self.itinerary.isFavorited ? [UIImage systemImageNamed:@"star.fill"] : [UIImage systemImageNamed:@"star"];
    [self.parseHandler updateItinerary:self.itinerary];
}

- (void) updateUIElementsCollection {
    if (self.itinerary.isOffline) {
        self.backgroundColor = [UIColor systemGrayColor];
    } else {
        self.backgroundColor = [UIColor systemBackgroundColor];
    }
    [self.starredImage setHidden:YES];
    
    self.titleLabel.text = self.collection.title;
    self.descriptionLabel.text = self.collection.snippet;
    [self.descriptionLabel sizeToFit];
    
    // Format date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM yyyy"];
    NSString *stringFromDate = [formatter stringFromDate:self.collection.lastUpdated];
    self.lastUpdateLabel.text = stringFromDate;
    
    // Get static thumbnail
    if(self.collection.locations.count > 0) {
        Location *firstLoc = self.collection.locations[0];
        self.mapImageView.image = firstLoc.staticMap;
    }
    else {
        self.mapImageView.image = [UIImage imageNamed:@"tray"];
    }
}

- (void) updateUIElementsLocation {
    [self.starredImage setHidden:YES];
    
    self.titleLabel.text = self.location.title;
    self.descriptionLabel.text = self.location.snippet;
    [self.descriptionLabel sizeToFit];
    
    // Get static thumbnail
    if (self.mapImageView != nil) {
        self.mapImageView.image = self.location.staticMap;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (self.showCheckmark) {
        self.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

@end
