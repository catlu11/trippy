//
//  PreferencesViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/15/22.
//

#import "PreferencesViewController.h"
#import "MapUtils.h"
#import "DateUtils.h"
#import "ItineraryPreferences.h"
#import "Location.h"

@interface PreferencesViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *snippetLabel;
@property (weak, nonatomic) IBOutlet UIImageView *staticMapImage;
@property (weak, nonatomic) IBOutlet UISwitch *prefEtaSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *prefTodSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *estStaySwitch;
@property (weak, nonatomic) IBOutlet UIDatePicker *etaPicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *todPicker;
@property (weak, nonatomic) IBOutlet UITextField *stayHrField;
@property (weak, nonatomic) IBOutlet UITextField *stayMinField;
@property (weak, nonatomic) IBOutlet UILabel *warningsLabel;

@property (assign, nonatomic) BOOL *didChange;
@end

@implementation PreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set location data
    self.nameLabel.text = self.location.title;
    self.snippetLabel.text = self.location.snippet;
    self.staticMapImage.image = [MapUtils getStaticMapImage:self.location.coord width:self.staticMapImage.frame.size.width height:self.staticMapImage.frame.size.height];
    
    // Set initial preferences
    if (self.preferences.preferredETA) {
        [self.prefEtaSwitch setOn:YES];
        self.etaPicker.hidden = NO;
        self.etaPicker.date = self.preferences.preferredETA;
    }
    if (self.preferences.preferredTOD) {
        [self.prefTodSwitch setOn:YES];
        self.todPicker.hidden = NO;
        self.todPicker.date = self.preferences.preferredTOD;
    }
    if ([self.preferences.stayDuration intValue] > 0) {
        [self.estStaySwitch setOn:YES];
        self.stayHrField.enabled = YES;
        self.stayMinField.enabled = YES;
        NSArray *hourMin = [DateUtils secondsToHourMin:[self.preferences.stayDuration intValue]];
        self.stayHrField.text = [hourMin[0] stringValue];
        self.stayMinField.text = [hourMin[1] stringValue];
    }
    [self.warningsLabel setHidden:YES];
    
    self.stayHrField.delegate = self;
    self.stayMinField.delegate = self;
}

- (IBAction)toggleEta:(id)sender {
    self.etaPicker.hidden = !self.prefEtaSwitch.isOn;
}

- (IBAction)toggleTod:(id)sender {
    self.todPicker.hidden = !self.prefTodSwitch.isOn;
}

- (IBAction)toggleStay:(id)sender {
    self.stayHrField.enabled = self.estStaySwitch.isOn;
    self.stayMinField.enabled = self.estStaySwitch.isOn;
}

- (IBAction)tapCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tapView:(id)sender {
    [self.stayHrField resignFirstResponder];
    [self.stayMinField resignFirstResponder];
}

- (IBAction)tapUpdate:(id)sender {
    NSDate *eta = self.prefEtaSwitch.isOn ? self.etaPicker.date : [NSNull null];
    NSDate *tod = self.prefTodSwitch.isOn ? self.todPicker.date : [NSNull null];
    NSNumber *stayTime = self.estStaySwitch ? [self stayTimeToSeconds] : @0;
    if ([eta isEqualToDate:self.preferences.preferredETA] && [eta isEqualToDate:self.preferences.preferredTOD] && [stayTime isEqualToValue:self.preferences.stayDuration]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        ItineraryPreferences *newPref = [[ItineraryPreferences alloc] initWithAttributes:eta preferredTOD:tod stayDuration:stayTime];
        if ([newPref isValid]) {
            [self.delegate didUpdatePreference:newPref location:self.location];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            NSLog(@"Invalid preferences");
            // TODO: Update warning label if invalid
        }
    }
}

- (NSNumber *) stayTimeToSeconds {
    NSString *hrString = self.stayHrField.text;
    NSString *minString = self.stayMinField.text;
    return [[NSNumber alloc] initWithInt:[hrString intValue] * 3600 + [minString intValue] * 60];
}

# pragma mark - UITextFieldDelegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSCharacterSet *numSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:string];
    return [numSet isSupersetOfSet:charSet];
}

@end
