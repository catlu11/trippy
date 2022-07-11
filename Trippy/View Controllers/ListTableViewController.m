//
//  ListTableViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "ListTableViewController.h"
#import "CacheDataHandler.h"

@interface ListTableViewController () <UITableViewDelegate, UITableViewDataSource, CacheDataHandlerDelegate>
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) CacheDataHandler *handler;
@end

@implementation ListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.data = [[NSMutableArray alloc] init];
    
    self.listTableView.dataSource = self;
    self.listTableView.delegate = self;
    self.listTableView.rowHeight = UITableViewAutomaticDimension;

    // Refresh setup
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.listTableView insertSubview:self.refreshControl atIndex:0];
    
    // Fetch handler
    self.handler = [[CacheDataHandler alloc] init];
    self.handler.delegate = self;
        
    [self refreshData];
}

- (void) refreshData {
    switch (self.listType) {
        case kCollection:
            [self.handler fetchSavedCollections];
            break;
        case kLocation:
            [self.handler fetchSavedLocations];
            break;
    }
}

- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    self.data = [[NSMutableArray alloc] init];
    [self refreshData];
    [self.refreshControl endRefreshing];
}

# pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    StaticMapCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StaticMapCell" forIndexPath:indexPath];
    switch (self.listType) {
        case kCollection:
            cell.collection = self.data[indexPath.row];
            break;
        case kLocation:
            cell.location = self.data[indexPath.row];
            break;
    }
    [cell updateUIElements:self.listType];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

# pragma mark - CacheDataHandlerDelegate

- (void) addFetchedCollection:(LocationCollection *)collection {
    if(self.listType == kCollection) {
        [self.data addObject:collection];
    }
    [self.listTableView reloadData];
}

- (void) addFetchedLocation:(Location *)location {
    if(self.listType == kLocation) {
        [self.data addObject:location];
    }
    [self.listTableView reloadData];
}

- (void) generalRequestFail:(NSError *)error {
    NSLog(@"Fetch saved handler: %@", error.description);
}

@end
