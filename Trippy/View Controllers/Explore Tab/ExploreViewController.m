//
//  ExploreViewController.m
//  Trippy
//
//  Created by Catherine Lu on 8/2/22.
//

#import "ExploreViewController.h"
#import "LoginViewController.h"
#import "LogoutHandler.h"
#import "SceneDelegate.h"
#import "MapsAPIManager.h"
#import "MapUtils.h"
#import "GoogleMaps/GMSAddress.h"
#import "JHUD.h"

#define VIEW_SHADOW_OPACITY 0.5;
#define VIEW_SHADOW_RADIUS 10;

@interface ExploreViewController () <LogoutHandlerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIView *locationView;
@property (weak, nonatomic) IBOutlet UIImageView *bannerImageView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) LogoutHandler *logoutHandler;
@end

@implementation ExploreViewController

- (void)viewWillAppear:(BOOL)animated {
    JHUD *hudView = [[JHUD alloc] initWithFrame:self.loadingView.bounds];
    hudView.messageLabel.text = @"Loading your trip info...";
    NSString *path = [[NSBundle mainBundle] pathForResource:@"paper_plane" ofType:@"gif"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    hudView.indicatorViewSize = CGSizeMake(200, 200);
    [hudView setGifImageData:data];
    [hudView showAtView:self.loadingView hudType:JHUDLoadingTypeGifImage];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up Parse interface
    self.logoutHandler = [[LogoutHandler alloc] init];
    self.logoutHandler.delegate = self;
    
    self.locationView.clipsToBounds = YES;
    self.locationView.layer.cornerRadius = 20;
    
    CLLocation *currentLoc = [[MapsAPIManager shared] currentLocation];
    [[MapsAPIManager shared] getUserAddressWithCompletion:^(GMSAddress * _Nonnull response, NSError * _Nonnull) {
        self.locationLabel.text = [NSString stringWithFormat:@"%@, %@", response.locality, response.administrativeArea];
        UIImage *banner = [MapUtils getStaticMapImage:currentLoc.coordinate width:self.bannerImageView.frame.size.width height:self.bannerImageView.frame.size.height];
        self.bannerImageView.image = banner;
        self.loadingView.hidden = YES;
    }];
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
