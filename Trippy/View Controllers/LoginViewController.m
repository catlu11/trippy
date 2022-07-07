//
//  LoginViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "LoginViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) UIAlertController *alert;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up empty field warning
    self.alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                  message:@"Cannot have empty username or password."
                                                  preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                             style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * _Nonnull action) {}];
    [self.alert addAction:okAction];
}

- (IBAction)tapRegister:(id)sender {
    if([self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""]) {
            [self presentViewController:self.alert animated:YES completion:nil];
            return;
        }
        
        // TODO: Register and log in using Parse client
}

- (IBAction)tapLogin:(id)sender {
    if([self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""]) {
            [self presentViewController:self.alert animated:YES completion:nil];
            return;
        }
        
        NSString *username = self.usernameField.text;
        NSString *password = self.passwordField.text;
        
        // TODO: Log in using Parse client
}

@end
