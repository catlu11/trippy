//
//  CreateItineraryViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import "CreateItineraryViewController.h"
#import "CacheDataHandler.h"
#import "ItineraryDetailViewController.h"
#import "Location.h"
#import "LocationCollection.h"
#import "Itinerary.h"
#import "DirectionsAPIManager.h"
#import "MapUtils.h"

@interface CreateItineraryViewController () <UIPickerViewDelegate, UIPickerViewDataSource, CacheDataHandlerDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UIButton *collectionButton;
@property (weak, nonatomic) IBOutlet UIPickerView *collectionPickerView;
@property (weak, nonatomic) IBOutlet UISearchBar *startingSearchBar;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) CacheDataHandler *colHandler;
@property (strong, nonatomic) UIAlertController *emptyAlert;

@property (strong, nonatomic) NSMutableArray *collectionData;
@property (strong, nonatomic) LocationCollection *selectedCol;
@property (strong, nonatomic) Location *selectedLoc;
@property (strong, nonatomic) Itinerary *createdItinerary;

@property (strong, nonatomic) NSMutableArray *fullLocationData;
@end

@implementation CreateItineraryViewController

- (void)viewDidLoad {
    self.listType = kLocation;
    self.showSelection = YES;
    
    [super viewDidLoad];
    
    // Set up search bar
    self.startingSearchBar.delegate = self;
    self.fullLocationData = self.data;
    
    // Set up Parse handler
    self.colHandler = [[CacheDataHandler alloc] init];
    self.colHandler.delegate = self;
    
    // Set up picker
    self.collectionPickerView.delegate = self;
    self.collectionPickerView.dataSource = self;
    self.collectionData = [[NSMutableArray alloc] init];
    
    [self.colHandler fetchSavedCollections];
    
    // Set up empty alert
    self.emptyAlert = [UIAlertController alertControllerWithTitle:@"Error"
                                                  message:@"Please select a collection and origin destination."
                                                  preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"OK"
                                             style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * _Nonnull action) {}];
    [self.emptyAlert addAction:doneAction];
}

- (IBAction)tapNext:(id)sender {
    if (self.selectedCol == nil || self.selectedLoc == nil) {
        [self presentViewController:self.emptyAlert animated:YES completion:nil];
    }
    else {
        NSString *apiUrl = [MapUtils generateDirectionsApiUrl:self.selectedCol origin:self.selectedLoc optimizeOrder:TRUE departureTime:nil];
        [[DirectionsAPIManager shared] getDirectionsWithCompletion:apiUrl completion:^(NSDictionary * _Nonnull response, NSError * _Nonnull) {
            if (response) {
                Itinerary *it = [[Itinerary alloc] initWithDictionary:response
                                                             prefJson:nil departure:[NSDate now] sourceCollection:self.selectedCol originLocation:self.selectedLoc name:self.nameField.text];
                [self.colHandler postNewItinerary:it];
            }
        }];
    }
}

- (IBAction)tapCollection:(id)sender {
    self.collectionPickerView.hidden = NO;
    self.collectionButton.titleLabel.text = @"";
}

- (IBAction)tapView:(id)sender {
    [self.nameField resignFirstResponder];
}

# pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"itineraryDetailSegue"]) {
        ItineraryDetailViewController *vc = segue.destinationViewController;
        vc.itinerary = self.createdItinerary;
    }
}

# pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
     return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.collectionData.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    LocationCollection *col = self.collectionData[row];
    return col.title;
}

# pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    LocationCollection *selected = self.collectionData[row];
    [self.collectionButton setTitle:selected.title forState:UIControlStateNormal];
    self.selectedCol = selected;
    self.collectionPickerView.hidden = YES;
}

# pragma mark - CacheDataHandlerDelegate

- (void) addFetchedCollection:(LocationCollection *)collection {
    [self.collectionData addObject:collection];
    [self.collectionPickerView reloadAllComponents];
}

- (void) postedItinerarySuccess:(Itinerary *)itinerary {
    self.createdItinerary = itinerary;
    [self performSegueWithIdentifier:@"itineraryDetailSegue" sender:nil];
    [self.navigationController popToRootViewControllerAnimated:NO]; // return Home tab to Home page
}

# pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedLoc = self.data[indexPath.row];
}

# pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.startingSearchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.startingSearchBar.showsCancelButton = NO;
    self.startingSearchBar.text = @"";
    [self.listTableView reloadData];
    [self.startingSearchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(Location *evaluatedObject, NSDictionary *bindings) {
            NSString *title = evaluatedObject.title;
            return [title rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound;}];
        self.data = [self.fullLocationData filteredArrayUsingPredicate:predicate];
    }
    else {
        self.data = self.fullLocationData;
    }
    [self.listTableView reloadData];
}

@end
