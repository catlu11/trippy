//
//  PreferencesViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/19/22.
//

#import "ItinerarySettingsViewController.h"

@interface ItinerarySettingsViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *mileageTextField;
@property (weak, nonatomic) IBOutlet UILabel *currentMileageLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *departureDatePicker;
@end

@implementation ItinerarySettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.departureDatePicker setDate:self.departure];
    self.mileageTextField.delegate = self;
    if (self.mileageConstraint) {
        self.mileageTextField.text = [self.mileageConstraint stringValue];
    }
    self.currentMileageLabel.text = [self.currentMileage stringValue];
}

- (IBAction)tapDone:(id)sender {
    int newMileage = [self.mileageTextField.text intValue];
    if (![self.departureDatePicker.date isEqualToDate:self.departure] || [self.mileageConstraint intValue] != newMileage) {
        [self.delegate didUpdatePreference:self.departureDatePicker.date newMileage:[[NSNumber alloc] initWithInt:newMileage]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tapView:(id)sender {
    [self.mileageTextField resignFirstResponder];
}

# pragma mark - UITextFieldDelegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSCharacterSet *numSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:string];
    return [numSet isSupersetOfSet:charSet];
}

@end
