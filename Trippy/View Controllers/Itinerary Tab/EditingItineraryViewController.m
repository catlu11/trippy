//
//  EditingItineraryViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/14/22.
//

#import "EditingItineraryViewController.h"
#import "WaypointPreferencesViewController.h"
#import "ItinerarySettingsViewController.h"
#import "ChooseRouteViewController.h"
#import "SelectableMap.h"
#import "EditPlaceCell.h"
#import "Itinerary.h"
#import "WaypointPreferences.h"
#import "LocationCollection.h"
#import "Location.h"
#import "RouteOption.h"
#import "TSPUtils.h"
#import "MapUtils.h"
#import "MapsAPIManager.h"
#import "RoutesHandler.h"
#import "CacheDataHandler.h"

#define PLACES_ROW_HEIGHT 70;
#define VIEW_SHADOW_OPACITY 0.45;
#define VIEW_SHADOW_RADIUS 7;

@interface EditingItineraryViewController () <UITableViewDelegate, UITableViewDataSource, EditPlaceCellDelegate, WaypointPreferencesDelegate, ItinerarySettingsDelegate, ChooseRouteDelegate, CacheDataHandlerDelegate>
@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UITableView *placesTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet SelectableMap *mapView;
@property (strong, nonatomic) NSArray *data;

@property (strong, nonatomic) Location *selectedLoc;
@property (strong, nonatomic) Itinerary *mutableItinerary;
@property (strong, nonatomic) NSArray *routeOptions;

@property (strong, nonatomic) CacheDataHandler *cacheHandler;

@end

@implementation EditingItineraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up copy of itinerary as data source
    self.mutableItinerary = [[Itinerary alloc] initWithDictionary:[self.baseItinerary toRouteDictionary]
                                                         prefJson:[self.baseItinerary toPrefsDictionary]
                                                        departure:self.baseItinerary.departureTime
                                                mileageConstraint:self.baseItinerary.mileageConstraint
                                                 sourceCollection:self.baseItinerary.sourceCollection
                                                   originLocation:self.baseItinerary.originLocation
                                                             name:self.baseItinerary.name];
    
    [self updateUI];
}

- (void) updateUI {
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
    
    self.editView.backgroundColor = [UIColor whiteColor];
    
    [self.loadingIndicator setHidesWhenStopped:YES];
    self.cacheHandler = [[CacheDataHandler alloc] init];
    self.cacheHandler.delegate = self;
}

- (IBAction)tapReroute:(id)sender {
    [self.loadingIndicator startAnimating];
    NSString *matrixUrl = [MapUtils generateMatrixApiUrl:self.mutableItinerary.sourceCollection
                                            origin:self.mutableItinerary.originLocation
                                     departureTime:self.mutableItinerary.departureTime];
    [[MapsAPIManager shared] getRouteMatrixWithCompletion:matrixUrl completion:^(NSDictionary * _Nonnull response, NSError * _Nonnull) {
        RoutesHandler *routeHandler = [[RoutesHandler alloc] initWithMatrix:response];
        [routeHandler calculateRoutes:self.mutableItinerary completion:^(NSArray * _Nonnull routes, NSError * _Nonnull) {
            if (routes.count == 1) {
                RouteOption *route = routes[0];
                [self selectedRoute:route];
            } else {
                self.routeOptions = routes;
                [self performSegueWithIdentifier:@"chooseRouteSegue" sender:nil];
            }
        }];
    }];
}

- (IBAction)tapEditPrefs:(id)sender {
    [self performSegueWithIdentifier:@"itPrefsSegue" sender:nil];
}

- (IBAction)tapEdit:(id)sender {
    [self.editView setHidden: !self.editView.isHidden];
}

- (IBAction)tapBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tapSave:(id)sender {
    [self.baseItinerary reinitialize:[self.mutableItinerary toRouteDictionary] prefJson:[self.mutableItinerary toPrefsDictionary] departure:self.mutableItinerary.departureTime mileageConstraint:self.mutableItinerary.mileageConstraint];
    [self.cacheHandler updateItinerary:self.baseItinerary];
}

- (void) didTapArrow {
    if (self.selectedLoc) {
        [self performSegueWithIdentifier:@"waypointPrefsSegue" sender:nil];
    }
}

- (void) itineraryHasChanged {
    // TODO: Create more informative change indicator
    self.editView.backgroundColor = [UIColor systemPinkColor];
}

# pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"waypointPrefsSegue"]) {
        WaypointPreferencesViewController *vc = [segue destinationViewController];
        vc.location = self.selectedLoc;
        vc.preferences = [self.mutableItinerary getPreference:self.selectedLoc];
        vc.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"itPrefsSegue"]) {
        ItinerarySettingsViewController *vc = [segue destinationViewController];
        vc.departure = self.mutableItinerary.departureTime;
        vc.mileageConstraint = self.mutableItinerary.mileageConstraint;
        vc.currentMileage = [self.mutableItinerary getTotalDistance];
        vc.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"chooseRouteSegue"]) {
        ChooseRouteViewController *vc = [segue destinationViewController];
        vc.routeOptions = self.routeOptions;
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
    [self performSegueWithIdentifier:@"waypointPrefsSegue" sender:nil];
}

# pragma mark - WaypointPreferencesDelegate

- (void) didUpdatePreference:(WaypointPreferences *)newPref location:(Location *)location {
    [self.mutableItinerary updatePreference:location pref:newPref];
    [self itineraryHasChanged];
}

# pragma mark - ItinerarySettingsDelegate

- (void) didUpdatePreference:(NSDate *)newDeparture newMileage:(NSNumber *)newMileage {
    self.mutableItinerary.departureTime = newDeparture;
    self.mutableItinerary.mileageConstraint = newMileage;
    [self itineraryHasChanged];
}

# pragma mark - CacheDataHandlerDelegate

- (void) updatedItinerarySuccess:(Itinerary *)itinerary {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate didSaveItinerary];
    }];
}

# pragma mark - ChooseRouteDelegate

- (void) selectedRoute:(RouteOption *)route {
    NSNumber *mileage = route.distance <= [self.mutableItinerary.mileageConstraint intValue] ? self.mutableItinerary.mileageConstraint : [[NSNumber alloc] initWithInt:route.distance];
    [self.mutableItinerary reinitialize:route.routeJson prefJson:[self.mutableItinerary toPrefsDictionary] departure:self.mutableItinerary.departureTime mileageConstraint:mileage];
    self.mutableItinerary.waypointOrder = route.waypoints;
    self.saveButton.hidden = NO;
    [self updateUI];
    [self.loadingIndicator stopAnimating];
}

- (void) cancel {
    [self.loadingIndicator stopAnimating];
}

@end
