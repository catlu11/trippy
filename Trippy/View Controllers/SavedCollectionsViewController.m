//
//  SavedCollectionsViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "SceneDelegate.h"
#import "SavedCollectionsViewController.h"
#import "LoginViewController.h"
#import "LogoutHandler.h"

@interface SavedCollectionsViewController () <LogoutHandlerDelegate>
@property (strong, nonatomic) LogoutHandler *handler;
@end

@implementation SavedCollectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up Parse interface
    self.handler = [[LogoutHandler alloc] init];
    self.handler.delegate = self;
}

- (IBAction)tapLogout:(id)sender {
    [self.handler logoutCurrentUser];
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
