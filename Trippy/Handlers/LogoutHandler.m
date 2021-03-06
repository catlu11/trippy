//
//  LogoutHandler.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "LogoutHandler.h"
#import "Parse/Parse.h"

@implementation LogoutHandler

- (void) logoutCurrentUser {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if(error) {
            [self.delegate logoutFail:error];
        } else {
            [self.delegate logoutSuccess];
        }
    }];
}

@end
