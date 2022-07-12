//
//  ItineraryDetailViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import "ItineraryDetailViewController.h"
#import "MapUtils.h"
#import "DirectionsAPIManager.h"
#import "CacheDataHandler.h"

@interface ItineraryDetailViewController () <CacheDataHandlerDelegate>
@property (strong, nonatomic) CacheDataHandler *postHandler;
@end

@implementation ItineraryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up Parse handler
    self.postHandler = [[CacheDataHandler alloc] init];
    self.postHandler.delegate = self;
    
    // Post itinerary
    NSString *apiUrl = [MapUtils generateDirectionsApiUrl:self.collection origin:self.originLoc optimize:TRUE departureTime:nil];
    [[DirectionsAPIManager shared] getDirectionsWithCompletion:apiUrl completion:^(NSDictionary * _Nonnull response, NSError * _Nonnull) {
        if (response) {
            self.itinerary = [[Itinerary alloc] initWithDictionary:response];
            self.itinerary.sourceCollection = self.collection;
            self.itinerary.originLocation = self.originLoc;
            self.itinerary.name = self.itineraryName;
            [self.postHandler postNewItinerary:self.itinerary];
        }
    }];
}

# pragma mark - CacheDataHandlerDelegate

- (void) postedItinerarySuccess {
    // do something
}

@end
