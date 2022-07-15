//
//  EditingItineraryViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/14/22.
//

#import "EditingItineraryViewController.h"
#import "PreferencesViewController.h"
#import "SelectableMap.h"
#import "EditPlaceCell.h"
#import "Itinerary.h"
#import "LocationCollection.h"
#import "Location.h"

@interface EditingItineraryViewController () <UITableViewDelegate, UITableViewDataSource, EditPlaceCellDelegate>
@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UITableView *placesTableView;
@property (weak, nonatomic) IBOutlet SelectableMap *mapView;
@property (weak, nonatomic) IBOutlet UIDatePicker *departureDatePicker;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) NSArray *data;

@property (strong, nonatomic) Location *selectedLoc;
@property (assign, nonatomic) int selectedIx;
@property (strong, nonatomic) Itinerary *mutableItinerary;
@end

@implementation EditingItineraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up copy of itinerary as data source
    self.mutableItinerary = [[Itinerary alloc] initWithDictionary:[self.baseItinerary toRouteDictionary]
                                                  prefJson:[self.baseItinerary toPrefsDictionary]
                                                 departure:self.baseItinerary.departureTime sourceCollection:self.baseItinerary.sourceCollection originLocation:self.baseItinerary.originLocation name:self.baseItinerary.name];
    
    // Set up map
    [self.mapView initWithBounds:self.mutableItinerary.bounds];
    [self.mapView addMarker:self.mutableItinerary.originLocation];
    for (Location *point in self.mutableItinerary.sourceCollection.locations) {
        [self.mapView addMarker:point];
    }
    [self.mapView addPolyline:self.mutableItinerary.overviewPolyline];
    
    // Set up table view
    self.placesTableView.dataSource = self;
    self.placesTableView.delegate = self;
    self.placesTableView.rowHeight = 70;
    self.data = [self.mutableItinerary getOrderedLocations];
    [self.placesTableView reloadData];
    
    // Add edit view shadow
    self.editView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.editView.layer.shadowOpacity = 0.45;
    self.editView.layer.shadowRadius = 7;
}

- (IBAction)tapReroute:(id)sender {
}

- (IBAction)tapEdit:(id)sender {
    [self.editView setHidden: !self.editView.isHidden];
}

- (IBAction)tapBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) didTapArrow {
    if (self.selectedLoc) {
        [self performSegueWithIdentifier:@"prefsSegue" sender:nil];
    }
}

# pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"prefsSegue"]) {
        PreferencesViewController *vc = [segue destinationViewController];
        vc.location = self.selectedLoc;
        vc.preferences = [[self.mutableItinerary prefsByWaypoint] objectAtIndex:self.selectedIx];
    }
}

# pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EditPlaceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditPlaceCell" forIndexPath:indexPath];
    Location *loc = nil;
    NSDate *estArrival = nil;
    NSDate *estDeparture = nil;
    if (indexPath.row == 0) {
        loc = self.mutableItinerary.originLocation;
        estDeparture = self.mutableItinerary.departureTime;
        [cell disableArrow];
    } else if (indexPath.row == self.data.count + 1) {
        loc = self.mutableItinerary.originLocation;
        estArrival = [self.mutableItinerary computeDeparture:(indexPath.row-2)];
        [cell disableArrow];
    } else {
        loc = self.data[indexPath.row-1];
        estArrival = [self.mutableItinerary computeArrival:(indexPath.row-1)];
        estDeparture = [self.mutableItinerary computeDeparture:(indexPath.row-1)];
        cell.waypointIndex = indexPath.row-1;
    }
    [cell updateUIElements:loc.title arrival:estArrival departure:estDeparture];
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mutableItinerary.sourceCollection.locations.count + 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Location *loc = nil;
    if (indexPath.row == 0 || indexPath.row == self.data.count + 1) {
        loc = self.mutableItinerary.originLocation;
    }
    else {
        loc = self.data[indexPath.row - 1];
    }
    [self.mapView setCameraToLoc:loc.coord animate:YES];
}

# pragma mark - EditPlaceCellDelegate

- (void) didTapArrow:(int)waypointIndex {
    self.selectedLoc = self.mutableItinerary.sourceCollection.locations[waypointIndex];
    self.selectedIx = waypointIndex;
    [self performSegueWithIdentifier:@"prefsSegue" sender:nil];
}

@end
