//
//  PreferencesViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/19/22.
//

#import "ItinerarySettingsViewController.h"
#import "MapUtils.h"

@interface ItinerarySettingsViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *mileageTextField;
@property (weak, nonatomic) IBOutlet UILabel *currentMileageLabel;
@property (weak, nonatomic) IBOutlet UITextField *budgetTextField;
@property (weak, nonatomic) IBOutlet UILabel *currentBudgetLabel;
@property (weak, nonatomic) IBOutlet UIView *mileageView;
@property (weak, nonatomic) IBOutlet UIView *budgetView;
@property (weak, nonatomic) IBOutlet UIDatePicker *departureDatePicker;
@property (weak, nonatomic) IBOutlet UIView *departureView;
@end

@implementation ItinerarySettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.departureView.layer.cornerRadius = 10;
    self.mileageView.layer.cornerRadius = 10;
    self.budgetView.layer.cornerRadius = 10;
    
    [self.departureDatePicker setDate:self.departure];
    
    self.mileageTextField.delegate = self;
    if (self.mileageConstraint) {
        double miles = [MapUtils metersToMiles:[self.mileageConstraint intValue]];
        self.mileageTextField.text = [NSString stringWithFormat:@"%.2f", miles];
    }
    self.currentMileageLabel.text = [self.currentMileage stringValue];
    
    self.budgetTextField.delegate = self;
    if (self.budgetConstraint) {
        self.budgetTextField.text = [self.budgetConstraint stringValue];
    }
    self.currentBudgetLabel.text = [self.currentBudget stringValue];
}

- (IBAction)tapDone:(id)sender {
    if ([self.departureDatePicker.date compare:[NSDate now]] == NSOrderedAscending) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Departure Date Error"
                                   message:@"Departure date must be in the future, please select a new date."
                                   preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {}];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        int newMileage = [MapUtils milesToMeters:[self.mileageTextField.text doubleValue]];
        int newBudget = [self.budgetTextField.text doubleValue];
        if (![self.departureDatePicker.date isEqualToDate:self.departure] || [self.mileageConstraint intValue] != newMileage || [self.budgetConstraint doubleValue] != newBudget) {
            [self.delegate didUpdatePreference:self.departureDatePicker.date newMileage:@(newMileage) newBudget:@(newBudget)];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
