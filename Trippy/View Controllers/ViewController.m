//
//  ViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/5/22.
//

#import "ViewController.h"
#import "SelectableMap.h"
#import "Location.h"
@import GooglePlaces;
@import GoogleMaps;

@interface ViewController () <UISearchBarDelegate, GMSAutocompleteTableDataSourceDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet SelectableMap *mapView;
@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;
@property (strong, nonatomic) GMSAutocompleteTableDataSource *tableDataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up Map View
    CLLocationCoordinate2D initialCenter = CLLocationCoordinate2DMake(47.629, -122.341);
    [self.mapView initWithCenter:initialCenter];

    // Set up Search Bar
    self.searchBar.delegate = self;
    
    // Set up drop down table
    self.tableDataSource = [[GMSAutocompleteTableDataSource alloc] init];
    self.tableDataSource.delegate = self;
    
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.locationBias = GMSPlaceRectangularLocationOption(initialCenter, initialCenter);
    filter.type = kGMSPlacesAutocompleteTypeFilterEstablishment;
    self.tableDataSource.autocompleteFilter = filter;
    
    self.itemsTableView.delegate = self.tableDataSource;
    self.itemsTableView.dataSource = self.tableDataSource;
}

- (IBAction)tapCollections:(id)sender {
    // TODO: Implement collections dropdown
}

- (IBAction)tapAdd:(id)sender {
    // TODO: Add to collection and close view
}

#pragma mark - GMSAutocompleteTableDataSourceDelegate

-(void)didUpdateAutocompletePredictionsForTableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource {
    [self.itemsTableView reloadData];
}

-(void)didRequestAutocompletePredictionsForTableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource {
    [self.itemsTableView reloadData];
}

- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource didAutocompleteWithPlace:(GMSPlace *)place {
}

- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource didFailAutocompleteWithError:(NSError *)error {
    NSLog(@"Error %@", error.description);
}

- (BOOL)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource didSelectPrediction:(GMSAutocompletePrediction *)prediction {
    [self searchBarCancelButtonClicked:self.searchBar];
    
    GMSPlaceField fields = (GMSPlaceFieldName | GMSPlaceFieldPlaceID | GMSPlaceFieldCoordinate);
    [[GMSPlacesClient sharedClient] fetchPlaceFromPlaceID:prediction.placeID placeFields:fields sessionToken:nil callback:^(GMSPlace * _Nullable result, NSError * _Nullable error) {
        if(error) {
            NSLog(@"An error occurred fetching place details%@", [error localizedDescription]);
        }
        else {
            Location *placeLoc = [[Location alloc] initWithPlace:result];
            [self.mapView clearMarkers];
            [self.mapView addMarker:placeLoc];
            [self.mapView setCameraToLoc:placeLoc.coord animate:YES];
        }
    }];
    return YES;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.tableDataSource sourceTextHasChanged:searchText];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    CLLocationCoordinate2D center = [self.mapView getCenter];
    self.tableDataSource.autocompleteFilter.locationBias = GMSPlaceRectangularLocationOption(center, center);
    self.itemsTableView.hidden = NO;
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.tableDataSource clearResults];
    [self.itemsTableView reloadData];
    self.itemsTableView.hidden = YES;
    [self.searchBar resignFirstResponder];
}

@end
