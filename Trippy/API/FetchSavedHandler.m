//
//  FetchSavedHandler.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "FetchSavedHandler.h"
#import "Collection.h"
#import "Parse/Parse.h"
#import "ParseUtils.h"

@implementation FetchSavedHandler

- (void) fetchSavedCollections:(PFUser *)user {
    PFQuery *query = [PFQuery queryWithClassName:@"Collection"];
    [query whereKey:@"createdBy" equalTo:[PFUser currentUser]];
    [query includeKeys:[ParseUtils getCollectionKeys]];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            [self.delegate generalRequestFail:error];
        } else {
            for(PFObject *obj in objects) {
                [ParseUtils collectionFromPFObj:obj completion:^(Collection * _Nonnull collection, NSError * _Nonnull) {
                    if(error) {
                        [self.delegate generalRequestFail:error];
                    } else {
                        [self.delegate addFetchedCollection:collection];
                    }
                }];
            }
        }
    }];
}

- (void) fetchSavedLocationsByUser:(PFUser *)user {
    // TODO: Implement
}

- (void) fetchSavedLocationsByCollection:(Collection *)collection {
    // TODO: Implement
}

@end
