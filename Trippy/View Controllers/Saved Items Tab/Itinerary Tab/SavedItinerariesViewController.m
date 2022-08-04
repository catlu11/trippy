//
//  HomeViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import "SavedItinerariesViewController.h"
#import "ParseUtils.h"
#import "ItineraryDetailViewController.h"
#import "LoginViewController.h"
#import "SceneDelegate.h"
#import "NetworkManager.h"
#import "CacheDataHandler.h"

@interface SavedItinerariesViewController ()
@property (strong, nonatomic) Itinerary *selectedIt;
@end

@implementation SavedItinerariesViewController

- (void)viewDidLoad {
    self.listType = kItinerary;
    self.showSelection = NO;
    
    [super viewDidLoad];
}

- (IBAction)tapCreate:(id)sender {
    if ([[NetworkManager shared] isConnected]) {
        [self performSegueWithIdentifier:@"createItinerarySegue" sender:nil];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Itinerary Creation Disabled"
                                   message:@"No internet connection, please try again later."
                                   preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                       handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

# pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"itineraryDetailSegueFromHome"]) {
        ItineraryDetailViewController *vc = segue.destinationViewController;
        vc.itinerary = self.selectedIt;
        vc.screenshotFlag = NO;
    }
}

# pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIt = self.data[indexPath.row];
    [self performSegueWithIdentifier:@"itineraryDetailSegueFromHome" sender:nil];
}

@end
