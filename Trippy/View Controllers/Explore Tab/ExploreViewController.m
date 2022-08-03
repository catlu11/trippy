//
//  ExploreViewController.m
//  Trippy
//
//  Created by Catherine Lu on 8/2/22.
//

#import "ExploreViewController.h"
#import "LoginViewController.h"
#import "LogoutHandler.h"
#import "GeoDataHandler.h"
#import "SceneDelegate.h"
#import "MapsAPIManager.h"
#import "MapUtils.h"
#import "GoogleMaps/GMSAddress.h"
#import "JHUD.h"
#import "Itinerary.h"

@interface ExploreViewController () <LogoutHandlerDelegate, GeoDataHandlerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIView *locationView;
@property (weak, nonatomic) IBOutlet UIImageView *bannerImageView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) LogoutHandler *logoutHandler;
@property (strong, nonatomic) GeoDataHandler *geoHandler;
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
    
    // Set up handlers
    self.logoutHandler = [[LogoutHandler alloc] init];
    self.logoutHandler.delegate = self;
    self.geoHandler = [[GeoDataHandler alloc] init];
    self.geoHandler.delegate = self;
    
    self.locationView.clipsToBounds = YES;
    self.locationView.layer.cornerRadius = 20;
    
    CLLocation *currentLoc = [[MapsAPIManager shared] currentLocation];
    [[MapsAPIManager shared] getUserAddressWithCompletion:^(GMSAddress * _Nonnull response, NSError * _Nonnull) {
        self.locationLabel.text = [NSString stringWithFormat:@"%@, %@", response.locality, response.administrativeArea];
        UIImage *banner = [MapUtils getStaticMapImage:currentLoc.coordinate width:self.bannerImageView.frame.size.width height:self.bannerImageView.frame.size.height];
        self.bannerImageView.image = banner;
        self.loadingView.hidden = YES;
    }];
    [self.geoHandler fetchItinerariesByCoordinate:currentLoc.coordinate rangeInKm:50.0];
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

# pragma mark - GeoDataHandlerDelegate

- (void)addFetchedNearbyItinerary:(nonnull Itinerary *)itinerary {
    NSLog(itinerary.name);
}

- (void)didAddAll {
    NSLog(@"finished trips near you fetch");
}

- (void)generalRequestFail:(nonnull NSError *)error {
    NSLog(@"something bad happened");
}

@end
