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
#import "ViewItineraryViewController.h"
#import "CacheDataHandler.h"
#import "NetworkManager.h"

@interface ItineraryDetailViewController () <EditingItineraryDelegate, SelectableMapDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet SelectableMap *mapView;
@end

@implementation ItineraryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateUI];
}

- (void)updateUI {
    // Set up map
    self.mapView.delegate = self;
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
    if ([[NetworkManager shared] isConnected]) {
        [self performSegueWithIdentifier:@"editItinerarySegue" sender:nil];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Itinerary Editing Disabled"
                                   message:@"No internet connection, please try again later."
                                   preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                       handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
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
    } else if ([[segue identifier] isEqualToString:@"viewItinerarySegue"]) {
        UINavigationController *navVc = segue.destinationViewController;
        ViewItineraryViewController *vc = [[navVc viewControllers] firstObject];
        vc.itinerary = self.itinerary;
    }
}

# pragma mark - EditingItineraryDelegate

- (void) didSaveItinerary {
    [self updateUI];
    self.screenshotFlag = YES;
}

# pragma mark - SelectableMapDelegate

- (void) didFinishLoading {
    if (self.screenshotFlag) {
        UIGraphicsBeginImageContext(self.mapView.frame.size);
        [self.mapView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.screenshotFlag = NO;
        
        self.itinerary.staticMap = screenshot;
        CacheDataHandler *handler = [[CacheDataHandler alloc] init];
        [handler updateItinerary:self.itinerary];
    }
}

@end
