//
//  ParseHandler.h
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ParseHandlerDelegate
- (void) loggedInSuccess;
- (void) signUpSuccess;
- (void) generalRequestFail:(NSError *)error; // TODO: Extend for more specific error behaviors
@end

@interface ParseHandler : NSObject
@property (nonatomic, weak) id<ParseHandlerDelegate> delegate;
- (void) logInWithUsername:(NSString *)username password:(NSString *)password;
- (void) signUpWithUsername:(NSString *)username password:(NSString *)password;
@end

NS_ASSUME_NONNULL_END
