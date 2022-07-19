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
#import "WaypointPreferences.h"
#import "LocationCollection.h"
#import "Location.h"

#define PLACES_ROW_HEIGHT 70;
#define VIEW_SHADOW_OPACITY 0.45;
#define VIEW_SHADOW_RADIUS 7;

@interface EditingItineraryViewController () <UITableViewDelegate, UITableViewDataSource, EditPlaceCellDelegate, PreferencesDelegate>
@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UITableView *placesTableView;
@property (weak, nonatomic) IBOutlet SelectableMap *mapView;
@property (weak, nonatomic) IBOutlet UIDatePicker *departureDatePicker;
@property (strong, nonatomic) NSArray *data;

@property (strong, nonatomic) Location *selectedLoc;
@property (strong, nonatomic) Itinerary *mutableItinerary;
@end

@implementation EditingItineraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up copy of itinerary as data source
    self.mutableItinerary = [[Itinerary alloc] initWithDictionary:[self.baseItinerary toRouteDictionary]
                                                         prefJson:[self.baseItinerary toPrefsDictionary]
                                                        departure:self.baseItinerary.departureTime
                                                 sourceCollection:self.baseItinerary.sourceCollection
                                                   originLocation:self.baseItinerary.originLocation
                                                             name:self.baseItinerary.name];
    
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
    self.placesTableView.rowHeight = PLACES_ROW_HEIGHT;
    self.data = [self.mutableItinerary getOrderedLocations];
    [self.placesTableView reloadData];
    
    // Add edit view shadow settings
    self.editView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.editView.layer.shadowOpacity = VIEW_SHADOW_OPACITY;
    self.editView.layer.shadowRadius = VIEW_SHADOW_RADIUS;
    
    self.departureDatePicker.date = self.baseItinerary.departureTime;
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

- (void) itineraryHasChanged {
    // TODO: Create more informative change indicator
    self.editView.backgroundColor = [UIColor systemPinkColor];
}

# pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"prefsSegue"]) {
        PreferencesViewController *vc = [segue destinationViewController];
        vc.location = self.selectedLoc;
        vc.preferences = [self.mutableItinerary getPreference:self.selectedLoc];
        vc.delegate = self;
    }
}

# pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EditPlaceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditPlaceCell" forIndexPath:indexPath];
    
    Location *loc = nil;
    NSDate *estArrival = nil;
    NSDate *estDeparture = nil;
    if (indexPath.row == 0) { // if origin location
        loc = self.mutableItinerary.originLocation;
        estDeparture = self.mutableItinerary.departureTime;
        [cell disableArrow];
    } else if (indexPath.row == self.data.count + 1) { // if ending destination (back to origin)
        loc = self.mutableItinerary.originLocation;
        estArrival = [self.mutableItinerary computeArrival:(indexPath.row - 1)];
        [cell disableArrow];
    } else { // if waypoint
        loc = self.data[indexPath.row - 1];
        estArrival = [self.mutableItinerary computeArrival:(indexPath.row - 1)];
        estDeparture = [self.mutableItinerary computeDeparture:(indexPath.row - 1)];
        cell.waypointIndex = indexPath.row - 1;
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
    self.selectedLoc = self.data[waypointIndex];
    [self performSegueWithIdentifier:@"prefsSegue" sender:nil];
}

# pragma mark - PreferencesDelegate

- (void) didUpdatePreference:(WaypointPreferences *)newPref location:(Location *)location {
    [self.mutableItinerary updatePreference:location pref:newPref];
    [self itineraryHasChanged];
}

- (IBAction)didChangeDate:(id)sender {
    if (![self.departureDatePicker.date isEqualToDate:self.baseItinerary.departureTime]) {
        [self itineraryHasChanged];
    }
}

@end
