//
//  ExploreViewController.m
//  Trippy
//
//  Created by Catherine Lu on 8/2/22.
//

#import "ExploreViewController.h"
#import "SceneDelegate.h"
#import "JHUD.h"
#import "Itinerary.h"
#import "NearbyTripCollectionCell.h"
#import "LocationManager.h"
#import "NetworkManager.h"
#import "MapsAPIManager.h"
#import "YelpAPIManager.h"
#import "MapUtils.h"
#import "LoginViewController.h"
#import "ItineraryDetailViewController.h"
#import "LogoutHandler.h"
#import "GeoDataHandler.h"

@interface ExploreViewController () <UICollectionViewDataSource, UICollectionViewDelegate, LogoutHandlerDelegate, GeoDataHandlerDelegate, LocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIView *locationView;
@property (weak, nonatomic) IBOutlet UIImageView *bannerImageView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

@property (weak, nonatomic) IBOutlet UICollectionView *nearbyCollectionView;
@property (strong, nonatomic) NSMutableArray *nearbyTripsData;

@property (strong, nonatomic) LogoutHandler *logoutHandler;
@property (strong, nonatomic) GeoDataHandler *geoHandler;

@property BOOL fetchedLocation;
@property BOOL fetchedTrips;
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
    
    self.fetchedTrips = NO;
    self.fetchedLocation = NO;
    self.loadingView.hidden = NO;
    [LocationManager shared].delegate = self;
    
    if (![[NetworkManager shared] isConnected]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Explore Tab Unavailable"
                                   message:@"No internet connection, please try again later."
                                   preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                       handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    // Set up handlers
    self.logoutHandler = [[LogoutHandler alloc] init];
    self.logoutHandler.delegate = self;
    self.geoHandler = [[GeoDataHandler alloc] init];
    self.geoHandler.delegate = self;
    
    self.locationView.clipsToBounds = YES;
    self.locationView.layer.cornerRadius = 20;
}

- (void)checkLoadingView {
    self.loadingView.hidden = self.fetchedTrips && self.fetchedLocation;
}

- (IBAction)tapLogout:(id)sender {
    [self.logoutHandler logoutCurrentUser];
}

# pragma mark - UICollectionViewDataSource

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NearbyTripCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NearbyTripCollectionCell" forIndexPath:indexPath];
    cell.it = [self.nearbyTripsData objectAtIndex:indexPath.item];
    [cell updateUI];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.nearbyTripsData.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ItineraryDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ItineraryDetailViewController"];
    vc.itinerary = self.nearbyTripsData[indexPath.item];
    [vc disableEdit];
    [self presentViewController:vc animated:YES completion:nil];
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
    [self.nearbyTripsData addObject:itinerary];
}

- (void)didAddAll {
    [self.nearbyCollectionView reloadData];
    self.fetchedTrips = YES;
    [self checkLoadingView];
}

- (void)generalRequestFail:(nonnull NSError *)error {
    NSLog(@"something bad happened");
}

# pragma mark - LocationManagerDelegate

- (void) didFetchLocation {
    CLLocation *currentLoc = [[LocationManager shared] currentLocation];
    [[MapsAPIManager shared] getUserAddressWithCompletion:currentLoc.coordinate completion:^(GMSAddress * _Nonnull response, NSError * _Nonnull) {
        if (response) {
            self.locationLabel.text = [NSString stringWithFormat:@"%@, %@", response.locality, response.administrativeArea];
            UIImage *banner = [MapUtils getStaticMapImage:currentLoc.coordinate width:self.bannerImageView.frame.size.width height:self.bannerImageView.frame.size.height];
            self.bannerImageView.image = banner;
            self.fetchedLocation = YES;
            [self checkLoadingView];
        }
    }];
    
    self.nearbyCollectionView.dataSource = self;
    self.nearbyCollectionView.delegate = self;
    self.nearbyTripsData = [[NSMutableArray alloc] init];
    [self.geoHandler fetchItinerariesByCoordinate:currentLoc.coordinate rangeInKm:50.0];
    
    [[YelpAPIManager shared] getBusinessSearchWithCompletion:@(currentLoc.coordinate.latitude) longitude:@(currentLoc.coordinate.longitude) completion:^(NSArray * _Nonnull results, NSError * _Nonnull) {
        NSLog(@"%@", results);
    }];
}

@end
