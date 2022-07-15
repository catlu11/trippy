//
//  JsonUtils.h
//  Trippy
//
//  Created by Catherine Lu on 7/14/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DateUtils : NSObject
+ (NSString *)formatDateAsISO8601:(NSDate *)date;
+ (NSDate *)isoStringToDate:(NSString *)isoString;
+ (int)aheadSecondsFrom1970:(NSDate *)date;
+ (NSArray *)secondsToHourMin:(int)seconds;
@end

NS_ASSUME_NONNULL_END
