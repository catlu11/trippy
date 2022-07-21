//
//  LocationOptionsViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/21/22.
//

#import "LocationOptionsViewController.h"
#import "Location.h"

@interface LocationOptionsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@end

@implementation LocationOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleField.text = self.loc.title;
    self.descTextView.text = self.loc.snippet;
    
    // Set textview UI
    [[self.descTextView layer] setBorderColor:[[UIColor systemGray5Color] CGColor]];
    [[self.descTextView layer] setBorderWidth:0.5];
    [[self.descTextView layer] setCornerRadius: self.descTextView.frame.size.width*0.03];
}

- (IBAction)tapCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tapSave:(id)sender {
    if ([self.titleField.text isEqualToString:@""] || [self.descTextView.text isEqualToString:@""]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                   message:@"Location title and description must be nonempty."
                                   preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {}];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self.delegate didSelectOptions:self.titleField.text desc:self.descTextView.text];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
