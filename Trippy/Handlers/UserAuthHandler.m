//
//  ParseHandler.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "UserAuthHandler.h"
#import "Parse/Parse.h"
#import "NetworkManager.h"

@implementation UserAuthHandler

- (void) logInWithUsername:(NSString *)username password:(NSString *)password {
    if ([[NetworkManager shared] isConnected]) {
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError * error) {
            if (error) {
                [self.delegate generalRequestFail:error];
            } else {
                [self.delegate loggedInSuccess];
                [[NetworkManager shared] initialFetchAll];
            }
        }];
    } else {
        [self.delegate offlineWarning];
    }
}

- (void) signUpWithUsername:(NSString *)username password:(NSString *)password {
    if ([[NetworkManager shared] isConnected]) {
        PFUser *newUser = [PFUser user];
        newUser.username = username;
        newUser.password = password;
        
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (error) {
                [self.delegate generalRequestFail:error];
            } else {
                [self.delegate signUpSuccess];
            }
        }];
    } else {
        [self.delegate offlineWarning];
    }
}

@end
