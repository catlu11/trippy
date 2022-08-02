//
//  ChooseRouteViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/20/22.
//

#import "ChooseRouteViewController.h"
#import "RouteCell.h"

#define ROW_HEIGHT 75

@interface ChooseRouteViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *routesTableView;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (strong, nonatomic) RouteOption *selectedRoute;
@end

@implementation ChooseRouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.routesTableView.delegate = self;
    self.routesTableView.dataSource = self;
    self.routesTableView.rowHeight = ROW_HEIGHT;
}

- (IBAction)tapCancel:(id)sender {
    [self.delegate cancel];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tapSelect:(id)sender {
    [self.delegate selectedRoute:self.selectedRoute];
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    RouteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"routeCell" forIndexPath:indexPath];
    cell.route = self.routeOptions[indexPath.row];
    [cell updateUIElements];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.routeOptions.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedRoute = self.routeOptions[indexPath.row];
}

@end
