//
//  ViewItineraryViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/25/22.
//

#import "ViewItineraryViewController.h"
#import "ItineraryItemCell.h"

@interface ViewItineraryViewController () <UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;
@property (strong, nonatomic) NSArray *data;
@end

@implementation ViewItineraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.itemsTableView.dataSource = self;
    self.itemsTableView.rowHeight = UITableViewAutomaticDimension;
}

- (IBAction)tapBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ItineraryItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StaticMapCell" forIndexPath:indexPath];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

@end
