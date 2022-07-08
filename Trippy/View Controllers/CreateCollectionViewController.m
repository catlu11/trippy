//
//  CreateCollectionViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/8/22.
//

#import "CreateCollectionViewController.h"
#import "FetchSavedHandler.h"
#import "SavedCollectionsViewController.h"

@interface CreateCollectionViewController () <FetchSavedHandlerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;
@property (strong, nonatomic) FetchSavedHandler *postHandler;
@end

@implementation CreateCollectionViewController

- (void)viewDidLoad {
    self.listType = kLocation;
    
    [super viewDidLoad];
    
    // Set textview UI
    [[self.descTextView layer] setBorderColor:[[UIColor systemGray5Color] CGColor]];
    [[self.descTextView layer] setBorderWidth:0.5];
    [[self.descTextView layer] setCornerRadius: self.descTextView.frame.size.width*0.03];
    
    // Set post handler
    self.postHandler = [[FetchSavedHandler alloc] init];
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
    Collection *col = [[Collection alloc] init];
    col.title = self.nameField.text;
    col.snippet = self.descTextView.text;
    col.locations = locations;
    [self.postHandler postNewCollection:col];
}

- (void) postedCollectionSuccess:(Collection *)col {
    [self.delegate createdNew:col];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tapCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
