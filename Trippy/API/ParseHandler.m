//
//  ParseHandler.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "ParseHandler.h"
#import "Parse/Parse.h"

@implementation ParseHandler

- (void) logInWithUsername:(NSString *)username password:(NSString *)password {
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError * error) {
        if (error) {
            [self.delegate generalRequestFail:error];
        } else {
            [self.delegate loggedInSuccess];
        }
    }];
}

- (void) signUpWithUsername:(NSString *)username password:(NSString *)password {
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
}

@end
