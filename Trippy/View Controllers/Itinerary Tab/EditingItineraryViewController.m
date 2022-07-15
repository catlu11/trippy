//
//  EditingItineraryViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/14/22.
//

#import "EditingItineraryViewController.h"
#import "SelectableMap.h"
#import "EditPlaceCell.h"
#import "Itinerary.h"
#import "LocationCollection.h"
#import "Location.h"

@interface EditingItineraryViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UITableView *placesTableView;
@property (weak, nonatomic) IBOutlet SelectableMap *mapView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) Location *selectedLoc;
@property (strong, nonatomic) Itinerary *itinerary;
@end

@implementation EditingItineraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up copy of itinerary as data source
    self.itinerary = [[Itinerary alloc] initWithDictionary:[self.baseItinerary toRouteDictionary]
                                                  prefJson:[self.baseItinerary toPrefsDictionary]
                                                 departure:self.baseItinerary.departureTime sourceCollection:self.baseItinerary.sourceCollection originLocation:self.baseItinerary.originLocation name:self.baseItinerary.name];
    
    // Set up map
    [self.mapView initWithBounds:self.itinerary.bounds];
    [self.mapView addMarker:self.itinerary.originLocation];
    for (Location *point in self.itinerary.sourceCollection.locations) {
        [self.mapView addMarker:point];
    }
    [self.mapView addPolyline:self.itinerary.overviewPolyline];
    
    // Set up table view
    self.placesTableView.dataSource = self;
    self.placesTableView.delegate = self;
    self.placesTableView.rowHeight = 70;
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
    [self performSegueWithIdentifier:@"prefsSegue" sender:nil];
}

# pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"prefsSegue"]) {
        // TODO
    }
}

# pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSArray *data = [self.itinerary getOrderedLocations];
    EditPlaceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditPlaceCell" forIndexPath:indexPath];
    Location *loc = nil;
    NSDate *estArrival = nil;
    NSDate *estDeparture = nil;
    if (indexPath.row == 0) {
        loc = self.itinerary.originLocation;
        estDeparture = self.itinerary.departureTime;
        [cell.arrowLabel setHidden:YES];
    } else if (indexPath.row == data.count+1) {
        loc = self.itinerary.originLocation;
        estArrival = [self.itinerary computeDeparture:(indexPath.row-2)];
        [cell.arrowLabel setHidden:YES];
    } else {
        loc = data[indexPath.row-1];
        estArrival = [self.itinerary computeArrival:(indexPath.row-1)];
        estDeparture = [self.itinerary computeDeparture:(indexPath.row-1)];
        [cell.arrowLabel setHidden:NO];
    }
    [cell updateUIElements:loc.title arrival:estArrival departure:estDeparture];
    if (!cell.arrowLabel.isHidden) {
        [cell addArrowTapWithSelector:self didTapArrow:@selector(didTapArrow)];
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itinerary.sourceCollection.locations.count + 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 || indexPath.row == self.itinerary.sourceCollection.locations.count + 1) {
        self.selectedLoc = self.itinerary.originLocation;
    } else {
        self.selectedLoc = self.itinerary.sourceCollection.locations[indexPath.row - 1];
    }
    [self.mapView setCameraToLoc:self.selectedLoc.coord animate:YES];
}

@end
