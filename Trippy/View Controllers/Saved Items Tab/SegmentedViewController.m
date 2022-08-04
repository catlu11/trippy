//
//  SegmentedViewController.m
//  Trippy
//
//  Created by Catherine Lu on 8/2/22.
//

#import "SegmentedViewController.h"
#import "LoginViewController.h"
#import "LogoutHandler.h"
#import "SceneDelegate.h"
#import "SavedItinerariesViewController.h"
#import "SavedCollectionsViewController.h"

typedef NS_ENUM(NSInteger, ViewControllerType) {
    kItineraryView = 0,
    kCollectionView = 1,
};

@interface SegmentedViewController () <LogoutHandlerDelegate>
@property (strong, nonatomic) LogoutHandler *logoutHandler;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (strong, nonatomic) SavedItinerariesViewController *itineraryVC;
@property (strong, nonatomic) SavedCollectionsViewController *collectionVC;
@property (strong, nonatomic) UIViewController *currentVC;
@end

@implementation SegmentedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up Parse interface
    self.logoutHandler = [[LogoutHandler alloc] init];
    self.logoutHandler.delegate = self;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.itineraryVC = [storyboard instantiateViewControllerWithIdentifier:@"SavedItinerariesViewController"];
    self.collectionVC = [storyboard instantiateViewControllerWithIdentifier:@"SavedCollectionsViewController"];
    
    [self displayCurrentTab:self.segmentedControl.selectedSegmentIndex];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.currentVC) {
        [self.currentVC viewWillDisappear:NO];
    }
}

- (UIViewController *)viewControllerForSelectedSegmentIndex:(int)index {
    switch (index) {
        case kItineraryView:
            return self.itineraryVC;
            break;
        case kCollectionView:
            return self.collectionVC;
            break;
        default:
            return nil;
    }
}

- (void)displayCurrentTab:(int)index {
    UIViewController *vc = [self viewControllerForSelectedSegmentIndex:index];
    if (vc) {
        [self addChildViewController:vc];
        [vc didMoveToParentViewController:self];
        vc.view.frame = self.contentView.bounds;
        [self.contentView addSubview:vc.view];
        self.currentVC = vc;
    }
}

- (IBAction)didSwitchTabs:(id)sender {
    UISegmentedControl *control = (UISegmentedControl *)sender;
    [self.currentVC.view removeFromSuperview];
    [self.currentVC removeFromParentViewController];
    [self displayCurrentTab:control.selectedSegmentIndex];
}

- (IBAction)tapLogout:(id)sender {
    [self.logoutHandler logoutCurrentUser];
}

# pragma mark - LogoutHandlerDelegate

- (void)logoutSuccess {
    SceneDelegate *appDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;
    NSLog(@"Successfully logged out user");
}

- (void)logoutFail:(NSError *)error {
    NSLog(@"Failed to log out user: %@", error.description);
}

- (void)offlineWarning {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Logout Failed"
                               message:@"No internet connection, please try again later."
                               preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                   handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
