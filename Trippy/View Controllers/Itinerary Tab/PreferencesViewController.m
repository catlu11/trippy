//
//  PreferencesViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/15/22.
//

#import "PreferencesViewController.h"
#import "MapUtils.h"
#import "ItineraryPreferences.h"
#import "Location.h"

@interface PreferencesViewController ()
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
        self.etaPicker.enabled = YES;
    }
    if (self.preferences.preferredTOD) {
        [self.prefTodSwitch setOn:YES];
        self.todPicker.enabled = YES;
    }
    if ([self.preferences.stayDuration intValue] > 0) {
        [self.estStaySwitch setOn:YES];
        self.stayHrField.enabled = YES;
        self.stayMinField.enabled = YES;
    }
    [self.warningsLabel setHidden:YES];
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

- (IBAction)tapUpdate:(id)sender {
    // TODO: Check if selected preferences are valid
    // TODO: Update warnings if invalid
    // TODO: Update preference, dismiss view, and fire delegate if valid
}

@end
