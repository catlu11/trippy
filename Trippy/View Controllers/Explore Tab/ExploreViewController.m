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
#import "YelpBusiness.h"
#import "NearbyTripCollectionCell.h"
#import "YelpBusinessCell.h"
#import "LocationManager.h"
#import "NetworkManager.h"
#import "MapsAPIManager.h"
#import "YelpAPIManager.h"
#import "MapUtils.h"
#import "LoginViewController.h"
#import "ItineraryDetailViewController.h"
#import "SearchMapViewController.h"
#import "LogoutHandler.h"
#import "GeoDataHandler.h"

#define CORNER_RADIUS 20
#define ROW_HEIGHT 107
#define LOADING_SIZE 200
#define NEARBY_RANGE_KM 50

@interface ExploreViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, LogoutHandlerDelegate, GeoDataHandlerDelegate, LocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIView *locationView;
@property (weak, nonatomic) IBOutlet UIImageView *bannerImageView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

@property (weak, nonatomic) IBOutlet UITableView *yelpTableView;
@property (weak, nonatomic) IBOutlet UICollectionView *nearbyCollectionView;
@property (strong, nonatomic) NSMutableArray *nearbyTripsData;
@property (strong, nonatomic) NSArray *yelpData;

@property (strong, nonatomic) LogoutHandler *logoutHandler;
@property (strong, nonatomic) GeoDataHandler *geoHandler;

@property (atomic) BOOL hasFetched;
@property (atomic) BOOL fetchedLocation;
@property (atomic) BOOL fetchedTrips;
@property (atomic) BOOL fetchedBusinesses;
@end

@implementation ExploreViewController

- (void)viewWillAppear:(BOOL)animated {
    JHUD *hudView = [[JHUD alloc] initWithFrame:self.loadingView.bounds];
    hudView.messageLabel.text = @"Loading your trip info...";
    NSString *path = [[NSBundle mainBundle] pathForResource:@"paper_plane" ofType:@"gif"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    hudView.indicatorViewSize = CGSizeMake(LOADING_SIZE, LOADING_SIZE);
    [hudView setGifImageData:data];
    [hudView showAtView:self.loadingView hudType:JHUDLoadingTypeGifImage];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fetchedTrips = NO;
    self.fetchedLocation = NO;
    self.fetchedBusinesses = NO;
    self.loadingView.hidden = NO;
    [LocationManager shared].delegate = self;
    [[LocationManager shared] getUserLocation];
    
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
    self.locationView.layer.cornerRadius = CORNER_RADIUS;
    
    self.yelpTableView.rowHeight = ROW_HEIGHT; // temporary until autolayouting
    self.yelpTableView.dataSource = self;
    self.yelpTableView.delegate = self;
    self.nearbyCollectionView.dataSource = self;
    self.nearbyCollectionView.delegate = self;
    
    CLLocation *loc = [[LocationManager shared] currentLocation];
    if ([[LocationManager shared] currentLocation]) {
        [self didFetchLocation];
    }
}

- (void)checkLoadingView {
    self.loadingView.hidden = self.fetchedLocation && self.fetchedTrips && self.fetchedBusinesses;
}

- (IBAction)tapLogout:(id)sender {
    [self.logoutHandler logoutCurrentUser];
}

# pragma mark - UICollectionViewDataSource

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NearbyTripCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NearbyTripCollectionCell" forIndexPath:indexPath];
    cell.itin = [self.nearbyTripsData objectAtIndex:indexPath.item];
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

# pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YelpBusinessCell *cell = [self.yelpTableView dequeueReusableCellWithIdentifier:@"YelpBusinessCell"];
    cell.business = [self.yelpData objectAtIndex:indexPath.item];
    [cell updateUI];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.yelpData.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YelpBusiness *business = self.yelpData[indexPath.row];
    UINavigationController *navController = [self.tabBarController.viewControllers objectAtIndex:2];
    SearchMapViewController *vc = [[navController viewControllers] firstObject];
    vc.initialSearch = business.name;
    vc.initialCoord = CLLocationCoordinate2DMake([business.latitude doubleValue], [business.longitude doubleValue]);
    [self.tabBarController setSelectedIndex:2];
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
    [self.nearbyCollectionView reloadData];
}

- (void)didAddAll {
    self.fetchedTrips = YES;
    [self checkLoadingView];
}

- (void)generalRequestFail:(nonnull NSError *)error {
    NSLog(@"Geoquery error: %@", error.description);
}

# pragma mark - LocationManagerDelegate

- (void) didFetchLocation {
    if (self.hasFetched) {
        return;
    }
    self.hasFetched = YES;
    CLLocation *currentLoc = [[LocationManager shared] currentLocation];
    __weak ExploreViewController *weakSelf = self;
    [[MapsAPIManager shared] getAddressWithCompletion:currentLoc.coordinate completion:^(GMSAddress * _Nonnull response, NSError * _Nonnull) {
        if (response) {
            __strong ExploreViewController *strongSelf = weakSelf;
            strongSelf.locationLabel.text = [NSString stringWithFormat:@"%@, %@", response.locality, response.administrativeArea];
            UIImage *banner = [MapUtils getStaticMapImage:currentLoc.coordinate width:strongSelf.bannerImageView.frame.size.width height:strongSelf.bannerImageView.frame.size.height];
            strongSelf.bannerImageView.image = banner;
            strongSelf.fetchedLocation = YES;
            [strongSelf checkLoadingView];
        }
    }];
    
    self.nearbyTripsData = [[NSMutableArray alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        __strong ExploreViewController *strongSelf = weakSelf;
        [strongSelf.geoHandler fetchItinerariesByCoordinate:currentLoc.coordinate rangeInKm:NEARBY_RANGE_KM];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[YelpAPIManager shared] getBusinessSearchWithCompletion:@(currentLoc.coordinate.latitude) longitude:@(currentLoc.coordinate.longitude) completion:^(NSArray * _Nonnull results, NSError * _Nonnull) {
            if (results) {
                __strong ExploreViewController *strongSelf = weakSelf;
                dispatch_async(dispatch_get_main_queue(), ^{
                    strongSelf.yelpData = results;
                    [strongSelf.yelpTableView reloadData];
                    strongSelf.fetchedBusinesses = YES;
                    [strongSelf checkLoadingView];
                });
            }
        }];
    });
}

@end
