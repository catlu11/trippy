//
//  JsonUtils.m
//  Trippy
//
//  Created by Catherine Lu on 7/14/22.
//

#import "DateUtils.h"

@implementation DateUtils

+ (NSString *)formatDateAsISO8601:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZZZZZ"];
    [dateFormatter setCalendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]];
    return [dateFormatter stringFromDate:date];
}

+ (NSDate *)isoStringToDate:(NSString *)isoString {
    NSISO8601DateFormatter *dateFormatter = [[NSISO8601DateFormatter alloc] init];
    return [dateFormatter dateFromString:isoString];
}

+ (int)aheadSecondsFrom1970:(NSDate *)date aheadBy:(int)aheadBy {
    double seconds = [date timeIntervalSince1970];
    return round(seconds) + aheadBy; //
}

+ (NSArray *)secondsToHourMin:(int)seconds {
    int hours = seconds / 3600;
    int minutes = (seconds - (hours * 3600)) / 60;
    return @[[NSNumber numberWithInt:hours], [NSNumber numberWithInt:minutes]];
}

@end
