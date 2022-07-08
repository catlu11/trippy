//
//  ListTableViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "ListTableViewController.h"
#import "FetchSavedHandler.h"

@interface ListTableViewController () <UITableViewDelegate, UITableViewDataSource, FetchSavedHandlerDelegate>
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) FetchSavedHandler *handler;
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
    self.handler = [[FetchSavedHandler alloc] init];
    self.handler.delegate = self;
        
    [self refreshData];
}

- (void) refreshData {
    if(self.listType == kCollection) {
        [self.handler fetchSavedCollections];
    } else if (self.listType == kLocation) {
        [self.handler fetchSavedLocations];
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
    if(self.listType == kCollection) {
        cell.collection = self.data[indexPath.row];
    } else if (self.listType == kLocation) {
        cell.location = self.data[indexPath.row];
    }
    [cell updateUIElements:self.listType];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

# pragma mark - FetchSavedHandlerDelegate

- (void) addFetchedCollection:(Collection *)collection {
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
