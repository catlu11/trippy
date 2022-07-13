//
//  CreateCollectionViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/8/22.
//

#import "CreateCollectionViewController.h"
#import "CacheDataHandler.h"
#import "SavedCollectionsViewController.h"
#import "LocationCollection.h"

@interface CreateCollectionViewController () <CacheDataHandlerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;
@property (strong, nonatomic) CacheDataHandler *postHandler;
@end

@implementation CreateCollectionViewController

- (void)viewDidLoad {
    self.listType = kLocation;
    self.showSelection = YES;
    
    [super viewDidLoad];
    
    // Set textview UI
    [[self.descTextView layer] setBorderColor:[[UIColor systemGray5Color] CGColor]];
    [[self.descTextView layer] setBorderWidth:0.5];
    [[self.descTextView layer] setCornerRadius: self.descTextView.frame.size.width*0.03];
    
    // Set post handler
    self.postHandler = [[CacheDataHandler alloc] init];
    self.postHandler.delegate = self;
}

- (IBAction)tapView:(id)sender {
    [self.nameField resignFirstResponder];
    [self.descTextView resignFirstResponder];
}

- (IBAction)tapDone:(id)sender {
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    for (int section = 0; section < [self.listTableView numberOfSections]; section++) {
        for (int row = 0; row < [self.listTableView numberOfRowsInSection:section]; row++) {
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
            UITableViewCell* cell = [self.listTableView cellForRowAtIndexPath:cellPath];
            if (cell.isSelected) {
                [locations addObject:self.data[row]];
            }
        }
    }
    LocationCollection *col = [[LocationCollection alloc] initWithParams:locations title:self.nameField.text snippet:self.descTextView.text];
    [self.postHandler postNewCollection:col];
}

- (void) postedCollectionSuccess:(LocationCollection *)col {
    [self.delegate createdNew:col];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tapCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
