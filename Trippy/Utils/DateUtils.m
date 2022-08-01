//
//  JsonUtils.m
//  Trippy
//
//  Created by Catherine Lu on 7/14/22.
//

#import "DateUtils.h"

@implementation DateUtils

+ (NSString *)formatDateAsIso8601:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    [dateFormatter setCalendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]];
    return [dateFormatter stringFromDate:date];
}

+ (NSDate *)iso8601StringToDate:(NSString *)isoString {
    NSISO8601DateFormatter *dateFormatter = [[NSISO8601DateFormatter alloc] init];
    NSDate *date = [dateFormatter dateFromString:isoString];
    return date;
}

+ (int)aheadSecondsFrom1970:(NSDate *)date aheadBy:(int)aheadBy {
    double seconds = [date timeIntervalSince1970];
    return round(seconds) + aheadBy; //
}

+ (TimeInHrMin)secondsToHourMin:(int)seconds {
    int hours = seconds / 3600;
    int minutes = (seconds - (hours * 3600)) / 60;
    TimeInHrMin time = {.hours = hours, .minutes = minutes};
    return time;
}

+ (int) hourMinToSeconds:(TimeInHrMin)time {
    return (time.hours * 3600) + (time.minutes * 60);
}

@end
