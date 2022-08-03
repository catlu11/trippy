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

+ (int)hourMinToSeconds:(TimeInHrMin)time {
    return (time.hours * 3600) + (time.minutes * 60);
}

+ (BOOL)isTimeInRange:(NSDate *)start end:(NSDate *)end time:(NSDate *)time {
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents *startComp = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:start];
    NSDateComponents *endComp = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:end];
    NSDateComponents *timeComp = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:time];
    if (timeComp.hour < startComp.hour || (timeComp.hour == startComp.hour && timeComp.minute < startComp.minute)) {
        return NO;
    }
    if (timeComp.hour > endComp.hour || (timeComp.hour == endComp.hour && timeComp.minute > endComp.minute)) {
        return NO;
    }
    return YES;
}

@end
