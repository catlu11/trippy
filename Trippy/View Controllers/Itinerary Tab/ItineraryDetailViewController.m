//
//  ItineraryDetailViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import "ItineraryDetailViewController.h"
#import "SelectableMap.h"

@interface ItineraryDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet SelectableMap *mapView;
@end

@implementation ItineraryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up map
    [self.mapView initWithBounds:self.itinerary.bounds];
    [self.mapView addMarker:self.itinerary.originLocation];
    for (Location *point in self.itinerary.sourceCollection.locations) {
        [self.mapView addMarker:point];
    }
    [self.mapView addPolyline:self.itinerary.overviewPolyline];
    
    // Set labels
    self.nameLabel.text = self.itinerary.name;
    self.detailsLabel.text = [NSString stringWithFormat:@"Origin: %@\nSource: %@", self.itinerary.originLocation.title, self.itinerary.sourceCollection.title];
}

- (IBAction)tapBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
