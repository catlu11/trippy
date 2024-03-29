//
//  ParseHandler.h
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol UserAuthHandlerDelegate
- (void)loggedInSuccess;
- (void)signUpSuccess;
- (void)offlineWarning;
- (void)generalRequestFail:(NSError *)error;
@end

@interface UserAuthHandler : NSObject
@property (nonatomic, weak) id<UserAuthHandlerDelegate> delegate;
- (void)logInWithUsername:(NSString *)username password:(NSString *)password;
- (void)signUpWithUsername:(NSString *)username password:(NSString *)password;
@end

NS_ASSUME_NONNULL_END
