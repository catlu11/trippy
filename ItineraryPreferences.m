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

- (NSDate *)preferredEtaStart {
    NSString *dateString = self.infoJson[@"preferredEtaStart"];
    if ([dateString isEqual:[NSNull null]]) {
        return nil;
    }
    return [DateUtils isoStringToDate:dateString];
}

- (void) setPreferredEtaStart:(NSDate *)preferredEtaStart {
    _infoJson[@"preferredEtaStart"] = [DateUtils formatDateAsISO8601:preferredEtaStart];
}

- (NSDate *)preferredEtaEnd {
    NSString *dateString = self.infoJson[@"preferredEtaEnd"];
    if ([dateString isEqual:[NSNull null]]) {
        return nil;
    }
    return [DateUtils isoStringToDate:dateString];
}

- (void) setPreferredEtaEnd:(NSDate *)preferredEtaEnd {
    _infoJson[@"preferredEtaEnd"] = [DateUtils formatDateAsISO8601:preferredEtaEnd];
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

- (instancetype)initWithAttributes:(NSDate * _Nullable)preferredEtaStart
                            preferredEtaEnd:(NSDate * _Nullable)preferredEtaEnd
                            stayDuration:(NSNumber *)stayDuration {
    self = [super init];
    
    if (self) {
        NSString *etaStart = [preferredEtaStart isEqual:[NSNull null]] ? [NSNull null] : [DateUtils formatDateAsISO8601:preferredEtaStart];
        NSString *etaEnd = [preferredEtaEnd isEqual:[NSNull null]] ? [NSNull null] : [DateUtils formatDateAsISO8601:preferredEtaEnd];
        NSDictionary *newDict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:etaStart, etaEnd, stayDuration, nil] forKeys:[NSArray arrayWithObjects:@"preferredEtaStart", @"preferredEtaEnd", @"stayDuration", nil]];
        self.infoJson = [newDict mutableCopy];
    }
    
    return self;
}

- (NSDictionary *)toDictionary {
    return self.infoJson;
}

- (BOOL) isValid {
    NSDate *etaStart = self.preferredEtaStart;
    NSDate *etaEnd = self.preferredEtaEnd;
    if (etaEnd != nil && etaStart != nil) {
        if ([self.preferredEtaStart compare:self.preferredEtaEnd] == NSOrderedDescending) {
            return NO;
        }
    }
    if ([self.stayDuration intValue] < 0) {
        return NO;
    }
    return YES;
}

@end
