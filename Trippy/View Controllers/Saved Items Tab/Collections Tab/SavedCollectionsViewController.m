//
//  SavedCollectionsViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "SceneDelegate.h"
#import "SavedCollectionsViewController.h"
#import "CreateCollectionViewController.h"
#import "SearchMapViewController.h"
#import "MapItemListViewController.h"
#import "LoginViewController.h"

@interface SavedCollectionsViewController () <CreateCollectionDelegate>
@end

@implementation SavedCollectionsViewController

- (void)viewDidLoad {
    self.listType = kCollection;
    self.showSelection = NO;
    
    [super viewDidLoad];
}

# pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    CreateCollectionViewController *vc = [segue destinationViewController];
    vc.delegate = self;
}

# pragma mark - CreateCollectionDelegate

- (void)createdNew:(LocationCollection *)col {
    [self.data insertObject:col atIndex:0];
    [self.listTableView reloadData];
}

@end
