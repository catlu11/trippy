//
//  HomeViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import "HomeViewController.h"
#import "ParseUtils.h"
#import "LogoutHandler.h"
#import "ItineraryDetailViewController.h"
#import "LoginViewController.h"
#import "SceneDelegate.h"

@interface HomeViewController () <LogoutHandlerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (strong, nonatomic) LogoutHandler *logoutHandler;
@property (strong, nonatomic) Itinerary *selectedIt;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    self.listType = kItinerary;
    self.showSelection = NO;
    
    [super viewDidLoad];
    
    self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome %@. Happy traveling!", [ParseUtils getLoggedInUsername]];
    
    // Set up Parse interface
    self.logoutHandler = [[LogoutHandler alloc] init];
    self.logoutHandler.delegate = self;
}

- (IBAction)tapLogout:(id)sender {
    [self.logoutHandler logoutCurrentUser];
}

# pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"itineraryDetailSegueFromHome"]) {
        ItineraryDetailViewController *vc = segue.destinationViewController;
        vc.itinerary = self.selectedIt;
    }
}

# pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIt = self.data[indexPath.row];
    [self performSegueWithIdentifier:@"itineraryDetailSegueFromHome" sender:nil];
}

# pragma mark - LogoutHandlerDelegate

- (void) logoutSuccess {
    SceneDelegate *appDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;
    NSLog(@"Successfully logged out user");
}

- (void) logoutFail:(NSError *)error {
    NSLog(@"Failed to log out user: %@", error.description);
}

@end
