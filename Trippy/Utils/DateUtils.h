//
//  JsonUtils.h
//  Trippy
//
//  Created by Catherine Lu on 7/14/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct TimeInHrMin {
    int hours;
    int minutes;
} TimeInHrMin;

@interface DateUtils : NSObject
+ (NSString *)formatDateAsIso8601:(NSDate *)date;
+ (NSDate *)iso8601StringToDate:(NSString *)isoString;
+ (int)aheadSecondsFrom1970:(NSDate *)date aheadBy:(int)aheadBy;
+ (TimeInHrMin)secondsToHourMin:(int)seconds;
+ (NSNumber *) hourMinToSeconds:(TimeInHrMin)time;
@end

NS_ASSUME_NONNULL_END
