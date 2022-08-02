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
#import "NetworkManager.h"

#define PLACES_ROW_HEIGHT 70;
#define VIEW_SHADOW_OPACITY 0.45;
#define VIEW_SHADOW_RADIUS 7;

@interface EditingItineraryViewController () <UITableViewDelegate, UITableViewDataSource, EditPlaceCellDelegate, WaypointPreferencesDelegate, ItinerarySettingsDelegate, ChooseRouteDelegate, CacheDataHandlerDelegate, SelectableMapDelegate>
@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UITableView *placesTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *editArrow;
@property BOOL viewIsOffscreen;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet SelectableMap *mapView;

@property (strong, nonatomic) NSArray *orderedData;
@property (strong, nonatomic) NSArray *omittedData;
@property (strong, nonatomic) Location *selectedLoc;
@property (strong, nonatomic) Itinerary *mutableItinerary;
@property (strong, nonatomic) NSArray *routeOptions;

@property (strong, nonatomic) CacheDataHandler *cacheHandler;
@property (assign, nonatomic) BOOL screenshotFlag;

@end

@implementation EditingItineraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up copy of itinerary as data source
    self.mutableItinerary = [[Itinerary alloc] initWithDictionary:[self.baseItinerary toRouteDictionary]
                                                          prefJson:[self.baseItinerary toPrefsDictionary]
                                                         departure:self.baseItinerary.departureTime
                                                 mileageConstraint:self.baseItinerary.mileageConstraint budgetConstraint:self.baseItinerary.budgetConstraint
                                                  sourceCollection:self.baseItinerary.sourceCollection
                                                    originLocation:self.baseItinerary.originLocation
                                                              name:self.baseItinerary.name
                                                       isFavorited:self.baseItinerary.isFavorited];
    self.mutableItinerary.staticMap = self.baseItinerary.staticMap;
    self.screenshotFlag = NO;
    self.cacheHandler = [[CacheDataHandler alloc] init];
    self.cacheHandler.delegate = self;
    [self updateUI];
    self.viewIsOffscreen = NO;
    
    // Set up swipe gestures
    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(animateEditViewRight)];
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(animateEditViewLeft)];
    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:rightSwipeGesture];
    [self.view addGestureRecognizer:leftSwipeGesture];
}

- (void) updateUI {
    // Set up map
    if ([[NetworkManager shared] isConnected]) {
        self.mapView.delegate = self;
        [self.mapView initWithBounds:self.mutableItinerary.bounds];
        [self.mapView addMarker:self.mutableItinerary.originLocation];
        for (Location *point in [self.mutableItinerary getOrderedLocations]) {
            [self.mapView addMarker:point];
        }
        [self.mapView addPolyline:self.mutableItinerary.overviewPolyline];
    } else {
        [self.mapView initWithStaticImage:self.mutableItinerary.staticMap];
    }

    // Set up table view
    self.placesTableView.dataSource = self;
    self.placesTableView.delegate = self;
    self.placesTableView.rowHeight = PLACES_ROW_HEIGHT;
    self.orderedData = [self.mutableItinerary getOrderedLocations];
    self.omittedData = [self.mutableItinerary getOmittedLocations];
    [self.placesTableView reloadData];
    
    // Add edit view shadow settings
    self.editView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.editView.layer.shadowOpacity = VIEW_SHADOW_OPACITY;
    self.editView.layer.shadowRadius = VIEW_SHADOW_RADIUS;
    
    self.editView.backgroundColor = [UIColor whiteColor];
    
    [self.loadingIndicator setHidesWhenStopped:YES];
}

- (IBAction)tapReroute:(id)sender {
    if (![[NetworkManager shared] isConnected]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"No internet connection"
                                   message:@"Please try again later."
                                   preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                       handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if ([self.mutableItinerary.departureTime compare:[NSDate now]] == NSOrderedAscending) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Departure Date Error"
                                   message:@"Departure date must be in the future, please select a new date."
                                   preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {}];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    [self.loadingIndicator startAnimating];
    NSString *matrixUrl = [MapUtils generateMatrixApiUrl:self.mutableItinerary.sourceCollection
                                            origin:self.mutableItinerary.originLocation
                                     departureTime:self.mutableItinerary.departureTime];
    [[MapsAPIManager shared] getRouteMatrixWithCompletion:matrixUrl completion:^(NSDictionary *response, NSError *error) {
        if (response) {
            RoutesHandler *routeHandler = [[RoutesHandler alloc] initWithMatrix:response];
            [routeHandler calculateRoutes:self.mutableItinerary completion:^(NSArray *routes, NSError *error) {
                if (routes) {
                    if (routes.count == 1) {
                        RouteOption *route = routes[0];
                        [self selectedRoute:route];
                    } else {
                        self.routeOptions = routes;
                        [self performSegueWithIdentifier:@"chooseRouteSegue" sender:nil];
                    }
                } else {
                    NSLog(@"Error: %@", error.description);
                }
            }];
        } else {
            NSLog(@"Error: %@", error.description);
        }
    }];
}

- (void)animateEditViewRight {
    if (self.viewIsOffscreen) {
        return;
    }
    CGRect rect = CGRectMake(self.editView.frame.origin.x, self.editView.frame.origin.y, self.editView.frame.size.width, self.editView.frame.size.height);
    rect.origin.x = rect.origin.x + 300;
    [UIView animateWithDuration:0.7f delay:0.0f options:nil animations:^{
        self.editView.frame = rect;
    } completion:^(BOOL finished) {
        self.editArrow.text = @"<";
        self.viewIsOffscreen = YES;
    }];
}

- (void)animateEditViewLeft {
    if (!self.viewIsOffscreen) {
        return;
    }
    CGRect rect = CGRectMake(self.editView.frame.origin.x, self.editView.frame.origin.y, self.editView.frame.size.width, self.editView.frame.size.height);
    rect.origin.x = rect.origin.x - 300;
    [UIView animateWithDuration:0.7f delay:0.0f options:nil animations:^{
        self.editView.frame = rect;
    } completion:^(BOOL finished) {
        self.editArrow.text = @">";
        self.viewIsOffscreen = NO;
    }];
}

- (IBAction)tapEditPrefs:(id)sender {
    [self performSegueWithIdentifier:@"itPrefsSegue" sender:nil];
}

- (IBAction)tapBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tapSave:(id)sender {
    [self.baseItinerary reinitialize:[self.mutableItinerary toRouteDictionary] prefJson:[self.mutableItinerary toPrefsDictionary] departure:self.mutableItinerary.departureTime mileageConstraint:self.mutableItinerary.mileageConstraint budgetConstraint:self.mutableItinerary.budgetConstraint];
    self.baseItinerary.staticMap = self.mutableItinerary.staticMap;
    [self.cacheHandler updateItinerary:self.baseItinerary];
}

- (void)itineraryHasChanged {
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
        vc.budgetConstraint = self.mutableItinerary.budgetConstraint;
        vc.currentMileage = [self.mutableItinerary getTotalDistance];
        vc.currentBudget = [self.mutableItinerary getTotalCost:NO];
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

    // If itinerary location
    if (indexPath.row == 0) { // if origin location
        loc = self.mutableItinerary.originLocation;
        estDeparture = self.mutableItinerary.departureTime;
        [cell disableArrow];
        cell.backgroundColor = [UIColor whiteColor];
    } else if (indexPath.row == self.orderedData.count + 1) { // if ending destination (back to origin)
        loc = self.mutableItinerary.originLocation;
        estArrival = [self.mutableItinerary computeArrival:(indexPath.row - 1)];
        [cell disableArrow];
        cell.backgroundColor = [UIColor whiteColor];
    } else if (indexPath.row < self.orderedData.count + 1) { // if waypoint
        loc = self.orderedData[indexPath.row - 1];
        estArrival = [self.mutableItinerary computeArrival:(indexPath.row - 1)];
        estDeparture = [self.mutableItinerary computeDeparture:(indexPath.row - 1)];
        cell.waypointIndex = indexPath.row - 1;
        [cell enableArrow];
        cell.backgroundColor = [UIColor whiteColor];
    } else {
        loc = self.omittedData[indexPath.row - self.orderedData.count - 2];
        [cell disableArrow];
        cell.backgroundColor = [UIColor systemGrayColor];
    }
    
    [cell updateUIElements:loc.title arrival:estArrival departure:estDeparture];
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.orderedData.count + self.omittedData.count + 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Location *loc = nil;
    if (indexPath.row == 0 || indexPath.row == self.orderedData.count + 1) {
        loc = self.mutableItinerary.originLocation;
    }
    else {
        loc = self.orderedData[indexPath.row - 1];
    }
    if (self.mapView.isEnabled) {
        [self.mapView setCameraToLoc:loc.coord animate:YES];
    }
}

# pragma mark - EditPlaceCellDelegate

- (void)didTapArrow:(int)waypointIndex {
    self.selectedLoc = self.orderedData[waypointIndex];
    [self performSegueWithIdentifier:@"waypointPrefsSegue" sender:nil];
}

# pragma mark - WaypointPreferencesDelegate

- (void)didUpdatePreference:(WaypointPreferences *)newPref location:(Location *)location {
    [self.mutableItinerary updatePreference:location pref:newPref];
    [self itineraryHasChanged];
}

# pragma mark - ItinerarySettingsDelegate

- (void)didUpdatePreference:(NSDate *)newDeparture newMileage:(NSNumber *)newMileage newBudget:(NSNumber *)newBudget {
    self.mutableItinerary.departureTime = newDeparture;
    self.mutableItinerary.mileageConstraint = newMileage;
    self.mutableItinerary.budgetConstraint = newBudget;
    [self itineraryHasChanged];
}

# pragma mark - CacheDataHandlerDelegate

- (void)updatedItinerarySuccess:(Itinerary *)itinerary {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate didSaveItinerary];
    }];
}

# pragma mark - ChooseRouteDelegate

- (void)selectedRoute:(RouteOption *)route {
    NSNumber *mileage = (route.distance <= [self.mutableItinerary.mileageConstraint intValue]) ? self.mutableItinerary.mileageConstraint : @(route.distance);
    NSNumber *cost = (route.cost <= [self.mutableItinerary.budgetConstraint intValue]) ? self.mutableItinerary.budgetConstraint : @(route.cost);
    [self.mutableItinerary reinitialize:route.routeJson prefJson:[self.mutableItinerary toPrefsDictionary] departure:self.mutableItinerary.departureTime mileageConstraint:mileage budgetConstraint:cost];
    self.mutableItinerary.waypointOrder = route.waypoints;
    self.saveButton.hidden = NO;
    self.screenshotFlag = YES;
    [self updateUI];
    [self.loadingIndicator stopAnimating];
}

- (void)cancel {
    [self.loadingIndicator stopAnimating];
}

# pragma mark - RouteCellDelegate
- (void)didTapArrow {
    if (self.selectedLoc) {
        [self performSegueWithIdentifier:@"waypointPrefsSegue" sender:nil];
    }
}

# pragma mark - SelectableMapDelegate

- (void) didFinishLoading {
    if (self.screenshotFlag) {
        UIGraphicsBeginImageContext(self.mapView.frame.size);
        [self.mapView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.screenshotFlag = NO;
        self.mutableItinerary.staticMap = screenshot;
    }
}

@end
