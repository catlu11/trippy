//
//  SavedCollectionsViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "SceneDelegate.h"
#import "SavedCollectionsViewController.h"
#import "CreateCollectionViewController.h"
#import "ListTableViewController.h"
#import "LoginViewController.h"
#import "LogoutHandler.h"

@interface SavedCollectionsViewController () <LogoutHandlerDelegate, CreateCollectionDelegate>
@property (strong, nonatomic) LogoutHandler *logoutHandler;
@end

@implementation SavedCollectionsViewController

- (void)viewDidLoad {
    self.listType = kCollection;
    
    [super viewDidLoad];
    
    // Set up Parse interface
    self.logoutHandler = [[LogoutHandler alloc] init];
    self.logoutHandler.delegate = self;
}

- (IBAction)tapLogout:(id)sender {
    [self.logoutHandler logoutCurrentUser];
}

# pragma mark - Navigation
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    CreateCollectionViewController *vc = [segue destinationViewController];
    vc.delegate = self;
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

# pragma mark - CreateCollectionDelegate
- (void) createdNew:(Collection *)col {
    [self.data insertObject:col atIndex:0];
    [self.listTableView reloadData];
}

@end
