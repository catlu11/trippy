//
//  LoginViewController.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "LoginViewController.h"
#import "UserAuthHandler.h"

@interface LoginViewController () <UserAuthHandlerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) UIAlertController *warningAlert;
@property (strong, nonatomic) UIAlertController *registerAlert;
@property (strong, nonatomic) UserAuthHandler *handler;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up Parse interface
    self.handler = [[UserAuthHandler alloc] init];
    self.handler.delegate = self;
    
    // Set up empty field warning
    self.warningAlert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                  message:@"Cannot have empty username or password."
                                                  preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                             style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * _Nonnull action) {}];
    [self.warningAlert addAction:okAction];
    
    // Set up registration alert
    self.registerAlert = [UIAlertController alertControllerWithTitle:@"Register Success"
                                                  message:@"Please re-enter your password to log in."
                                                  preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Done"
                                             style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * _Nonnull action) {}];
    [self.registerAlert addAction:doneAction];
}

- (IBAction)tapRegister:(id)sender {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    if([username isEqual:@""] || [password isEqual:@""]) {
        [self presentViewController:self.warningAlert animated:YES completion:nil];
        return;
    }
    [self.handler signUpWithUsername:username password:password];
}

- (IBAction)tapLogin:(id)sender {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    if([username isEqual:@""] || [password isEqual:@""]) {
        [self presentViewController:self.warningAlert animated:YES completion:nil];
        return;
    }
    [self.handler logInWithUsername:username password:password];
}

// Enable tapping outside field to dismiss keyboard
- (IBAction)tapView:(id)sender {
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

# pragma mark - UserAuthHandlerDelegate

- (void)generalRequestFail:(NSError *)error {
    NSLog(@"Parse request failed: %@", error.description);
}

- (void)loggedInSuccess {
    NSLog(@"User logged in successfully");
    [self performSegueWithIdentifier:@"loginSegue" sender:nil];
}

- (void)signUpSuccess {
    NSLog(@"User registered successfully");
    [self presentViewController:self.registerAlert animated:YES completion:nil];
    self.passwordField.text = @"";
}

- (void)offlineWarning {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"No internet connection"
                               message:@"Please try again later."
                               preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                   handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
