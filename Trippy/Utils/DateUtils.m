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
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    [dateFormatter setCalendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]];
    return [dateFormatter stringFromDate:date];
}

+ (NSDate *)isoStringToDate:(NSString *)isoString {
    NSISO8601DateFormatter *dateFormatter = [[NSISO8601DateFormatter alloc] init];
    return [dateFormatter dateFromString:isoString];
}

@end
