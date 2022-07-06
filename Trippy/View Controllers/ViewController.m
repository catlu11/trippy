//
//  ViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/5/22.
//

#import "ViewController.h"
#import "SelectableMap.h"
#import "Location.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet SelectableMap *mapView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Location *initialCenter = [[Location alloc] initWithParams:@"Meta Westlake" snippet:@"Here we are!" latitude:47.629 longitude:-122.341];
    [self.mapView initWithCenter:initialCenter];
    [self.mapView addMarker:initialCenter];
}

@end
