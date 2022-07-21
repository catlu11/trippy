//
//  ItineraryDetailViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import "ItineraryDetailViewController.h"
#import "SelectableMap.h"
#import "Itinerary.h"
#import "LocationCollection.h"
#import "Location.h"
#import "EditingItineraryViewController.h"

@interface ItineraryDetailViewController () <EditingItineraryDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet SelectableMap *mapView;
@end

@implementation ItineraryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateUI];
}

- (void) updateUI {
    // Set up map
    [self.mapView initWithBounds:self.itinerary.bounds];
    [self.mapView addMarker:self.itinerary.originLocation];
    for (Location *point in [self.itinerary getOrderedLocations]) {
        [self.mapView addMarker:point];
    }
    [self.mapView addPolyline:self.itinerary.overviewPolyline];
    
    // Set labels
    self.nameLabel.text = self.itinerary.name;
    self.detailsLabel.text = [NSString stringWithFormat:@"Origin: %@\nSource: %@", self.itinerary.originLocation.title, self.itinerary.sourceCollection.title];
}

- (IBAction)tapEdit:(id)sender {
    [self performSegueWithIdentifier:@"editItinerarySegue" sender:nil];
}

- (IBAction)tapBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"editItinerarySegue"]) {
        EditingItineraryViewController *vc = segue.destinationViewController;
        vc.baseItinerary = self.itinerary;
        vc.delegate = self;
    }
}

# pragma mark - EditingItineraryDelegate
- (void) didSaveItinerary {
    [self updateUI];
}

@end
