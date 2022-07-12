//
//  ItineraryDetailViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/11/22.
//

#import "ItineraryDetailViewController.h"
#import "MapUtils.h"
#import "DirectionsAPIManager.h"

@interface ItineraryDetailViewController ()

@end

@implementation ItineraryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Test code
    //    NSString *apiUrl = [MapUtils generateDirectionsApiUrl:self.collection origin:self.originLoc optimize:TRUE departureTime:nil];
    //    [[DirectionsAPIManager shared] getDirectionsWithCompletion:apiUrl completion:^(NSDictionary * _Nonnull response, NSError * _Nonnull) {
    //        if (response) {
    //            NSLog(@"%@", response);
    //        }
    //    }];
}

- (IBAction)tapBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
