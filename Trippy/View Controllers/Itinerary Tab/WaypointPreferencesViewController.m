//
//  PreferencesViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/15/22.
//

#import "WaypointPreferencesViewController.h"
#import "MapUtils.h"
#import "DateUtils.h"
#import "WaypointPreferences.h"
#import "Location.h"

@interface WaypointPreferencesViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *snippetLabel;
@property (weak, nonatomic) IBOutlet UIImageView *staticMapImage;
@property (weak, nonatomic) IBOutlet UISwitch *prefEtaSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *estStaySwitch;
@property (weak, nonatomic) IBOutlet UIDatePicker *etaStartPicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *etaEndPicker;
@property (weak, nonatomic) IBOutlet UITextField *stayHrField;
@property (weak, nonatomic) IBOutlet UITextField *stayMinField;
@property (weak, nonatomic) IBOutlet UILabel *toRangeLabel;

@property (assign, nonatomic) BOOL *didChange;
@end

@implementation WaypointPreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set location data
    self.nameLabel.text = self.location.title;
    self.snippetLabel.text = self.location.snippet;
    self.staticMapImage.image = [MapUtils getStaticMapImage:self.location.coord width:self.staticMapImage.frame.size.width height:self.staticMapImage.frame.size.height];
    
    // Set initial preferences
    if (self.preferences.preferredEtaStart) {
        [self.prefEtaSwitch setOn:YES];
        self.etaStartPicker.hidden = NO;
        self.etaStartPicker.date = self.preferences.preferredEtaStart;
        self.etaEndPicker.hidden = NO;
        self.etaEndPicker.date = self.preferences.preferredEtaEnd;
        [self.toRangeLabel setHidden:NO];
    }
    if ([self.preferences.stayDurationInSeconds intValue] > 0) {
        [self.estStaySwitch setOn:YES];
        self.stayHrField.enabled = YES;
        self.stayMinField.enabled = YES;
        TimeInHrMin hourMin = [DateUtils secondsToHourMin:[self.preferences.stayDurationInSeconds intValue]];
        self.stayHrField.text = [NSString stringWithFormat:@"%i", hourMin.hours];
        self.stayMinField.text = [NSString stringWithFormat:@"%i", hourMin.minutes];
    }
    
    // Set text field delegates
    self.stayHrField.delegate = self;
    self.stayMinField.delegate = self;
}

- (IBAction)toggleEta:(id)sender {
    self.etaStartPicker.hidden = !self.prefEtaSwitch.isOn;
    self.etaEndPicker.hidden = !self.prefEtaSwitch.isOn;
    self.toRangeLabel.hidden = !self.prefEtaSwitch.isOn;
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
    NSDate *etaStart = self.prefEtaSwitch.isOn ? self.etaStartPicker.date : [NSNull null];
    NSDate *etaEnd = self.prefEtaSwitch.isOn ? self.etaEndPicker.date : [NSNull null];
    TimeInHrMin fieldTime = {.hours = [self.stayHrField.text intValue], .minutes=[self.stayMinField.text intValue]};
    NSNumber *stayTime = self.estStaySwitch ? [DateUtils hourMinToSeconds:fieldTime] : @0;
    
    if ([etaStart isEqualToDate:self.preferences.preferredEtaStart] && [etaEnd isEqualToDate:self.preferences.preferredEtaEnd] && [stayTime isEqualToValue:self.preferences.stayDurationInSeconds]) { // if no changes made
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        WaypointPreferences *newPref = [[WaypointPreferences alloc] initWithAttributes:etaStart preferredEtaEnd:etaEnd stayDuration:stayTime];
        if ([newPref isValid]) {
            [self.delegate didUpdatePreference:newPref location:self.location];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            NSLog(@"Invalid preferences");
            // TODO: Update a warning label if invalid
        }
    }
}

# pragma mark - UITextFieldDelegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSCharacterSet *numSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:string];
    return [numSet isSupersetOfSet:charSet];
}

@end
