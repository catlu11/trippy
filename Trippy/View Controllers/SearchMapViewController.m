//
//  ViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/5/22.
//

#import "SearchMapViewController.h"
#import "SelectableMap.h"
#import "Location.h"
#import "ParseUtils.h"
#import "FetchSavedHandler.h"
@import GooglePlaces;
@import GoogleMaps;

@interface SearchMapViewController () <UISearchBarDelegate, GMSAutocompleteTableDataSourceDelegate, UIPickerViewDelegate, UIPickerViewDataSource, FetchSavedHandlerDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet SelectableMap *mapView;
@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;
@property (strong, nonatomic) GMSAutocompleteTableDataSource *tableDataSource;
@property (weak, nonatomic) IBOutlet UIButton *collectionButton;
@property (weak, nonatomic) IBOutlet UIPickerView *collectionPickerView;
@property (strong, nonatomic) FetchSavedHandler *handler;
@property (strong, nonatomic) Location *selectedLoc;
@property (strong, nonatomic) Collection *selectedCol;
@property (strong, nonatomic) NSMutableArray *data;
@end

@implementation SearchMapViewController

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
    
    
    // Set up Parse handler
    self.handler = [[FetchSavedHandler alloc] init];
    self.handler.delegate = self;
    
    // Set up picker
    self.collectionPickerView.delegate = self; // Also, can be done from IB, if you're using
    self.collectionPickerView.dataSource = self;
    self.data = [[NSMutableArray alloc] init];
    
    [self.handler fetchSavedCollections];
}

- (IBAction)tapAdd:(id)sender {
    if(self.selectedLoc && self.selectedCol) {
        [self.handler postNewLocation:self.selectedLoc collection:self.selectedCol];
    }
}

- (IBAction)tapCollection:(id)sender {
    self.collectionPickerView.hidden = NO;
    self.collectionButton.titleLabel.text = @"";
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
            Location *placeLoc = [[Location alloc] initWithPlace:result user:[ParseUtils getLoggedInUserId]];
            [self.mapView clearMarkers];
            [self.mapView addMarker:placeLoc];
            [self.mapView setCameraToLoc:placeLoc.coord animate:YES];
            self.selectedLoc = placeLoc;
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

# pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
     return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.data.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    Collection *col = self.data[row];
    return col.title;
}

# pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    Collection *selected = self.data[row];
    [self.collectionButton setTitle:selected.title forState:UIControlStateNormal];
    self.selectedCol = selected;
    self.collectionPickerView.hidden = YES;
}

# pragma mark - FetchSavedHandlerDelegate

- (void) addFetchedCollection:(Collection *)collection {
    [self.data addObject:collection];
    [self.collectionPickerView reloadAllComponents];
}

@end