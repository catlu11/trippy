//
//  LogoutHandler.h
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LogoutHandlerDelegate
- (void) logoutSuccess;
- (void) logoutFail:(NSError *)error; // TODO: Extend for more specific error behaviors
@end

@interface LogoutHandler : NSObject
@property (nonatomic, weak) id<LogoutHandlerDelegate> delegate;
- (void) logoutCurrentUser;
@end

NS_ASSUME_NONNULL_END
