//
//  LogoutHandler.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "LogoutHandler.h"
#import "Parse/Parse.h"
#import "NetworkManager.h"
#import "CoreDataHandler.h"

@implementation LogoutHandler

- (void) logoutCurrentUser {
    if ([[NetworkManager shared] isConnected]) {
        [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
            if(error) {
                [self.delegate logoutFail:error];
            } else {
                [self.delegate logoutSuccess];
                [[CoreDataHandler shared] clearEntity:@"Location"];
                [[CoreDataHandler shared] clearEntity:@"LocationCollection"];
                [[CoreDataHandler shared] clearEntity:@"Itinerary"];
            }
        }];
    } else {
        [self.delegate offlineWarning];
    }
}

@end
