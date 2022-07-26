//
//  ViewItineraryViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/25/22.
//

#import "ViewItineraryViewController.h"
#import "ItineraryItemCell.h"
#import "Itinerary.h"

@interface ViewItineraryViewController () <UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;
@property (strong, nonatomic) NSArray *data;
@end

@implementation ViewItineraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     
    self.data = [self.itinerary getInstructions];
    
    self.itemsTableView.dataSource = self;
    self.itemsTableView.rowHeight = UITableViewAutomaticDimension;
    self.itemsTableView.separatorColor = [UIColor clearColor];
    [self.itemsTableView reloadData];
}

- (IBAction)tapBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ItineraryItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItineraryItemCell" forIndexPath:indexPath];
    cell.instructionLabel.text = self.data[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

@end
