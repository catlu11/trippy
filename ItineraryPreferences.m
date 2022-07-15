//
//  ItineraryItemPreferences.m
//  Trippy
//
//  Created by Catherine Lu on 7/13/22.
//

#import "ItineraryPreferences.h"
#import "DateUtils.h"

@interface ItineraryPreferences ()
@property (strong, nonatomic) NSMutableDictionary *infoJson;
@end

@implementation ItineraryPreferences

- (NSDate *)preferredETA {
    NSString *dateString = self.infoJson[@"preferredEta"];
    if ([dateString isEqual:[NSNull null]]) {
        return nil;
    }
    return [DateUtils isoStringToDate:dateString];
}

- (void) setPreferredEta:(NSDate *)preferredEta {
    _infoJson[@"preferredEta"] = [DateUtils formatDateAsISO8601:preferredEta];
}

- (NSDate *)preferredTOD {
    NSString *dateString = self.infoJson[@"preferredTod"];
    if ([dateString isEqual:[NSNull null]]) {
        return nil;
    }
    return [DateUtils isoStringToDate:dateString];
}

- (void) setPreferredTod:(NSDate *)preferredTOD {
    _infoJson[@"preferredTod"] = [DateUtils formatDateAsISO8601:preferredTOD];
}

- (NSNumber *)stayDuration {
    NSNumber *val = _infoJson[@"stayDuration"];
    return val;
}

- (void) setStayDuration:(NSNumber *)stayDuration {
    _infoJson[@"stayDuration"] = stayDuration;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    
    if (self) {
        self.infoJson = [dict mutableCopy];
    }

    return self;
}

- (void)reinitialize:(NSDictionary *)dict {
    self.infoJson = [dict mutableCopy];
}

- (instancetype)initWithAttributes:(NSDate * _Nullable)preferredETA
                            preferredTOD:(NSDate * _Nullable)preferredTOD
                            stayDuration:(NSNumber *)stayDuration {
    self = [super init];
    
    if (self) {
        NSString *eta = [preferredETA isEqual:[NSNull null]] ? [NSNull null] : [DateUtils formatDateAsISO8601:preferredETA];
        NSString *tod = [preferredTOD isEqual:[NSNull null]] ? [NSNull null] : [DateUtils formatDateAsISO8601:preferredTOD];
        NSDictionary *newDict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:eta, tod, stayDuration, nil] forKeys:[NSArray arrayWithObjects:@"preferredEta", @"preferredTod", @"stayDuration", nil]];
        self.infoJson = [newDict mutableCopy];
    }
    
    return self;
}

- (NSDictionary *)toDictionary {
    return self.infoJson;
}

- (BOOL) isValid {
    NSDate *eta = self.preferredETA;
    NSDate *tod = self.preferredTOD;
    if (tod != nil && eta != nil) {
        if ([self.preferredETA compare:self.preferredTOD] == NSOrderedDescending) {
            return NO;
        }
    }
    if ([self.stayDuration intValue] < 0) {
        return NO;
    }
    return YES;
}

@end
