//
//  SavedCollectionsViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "SceneDelegate.h"
#import "SavedCollectionsViewController.h"
#import "ListTableViewController.h"
#import "LoginViewController.h"
#import "LogoutHandler.h"

@interface SavedCollectionsViewController () <LogoutHandlerDelegate>
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
