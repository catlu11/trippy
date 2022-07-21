//
//  ItineraryItemPreferences.m
//  Trippy
//
//  Created by Catherine Lu on 7/13/22.
//

#import "WaypointPreferences.h"
#import "DateUtils.h"

@interface WaypointPreferences ()
@property (strong, nonatomic) NSMutableDictionary *infoJson;
@end

@implementation WaypointPreferences

- (NSDate *)preferredEtaStart {
    NSString *dateString = self.infoJson[@"preferredEtaStart"];
    if ([dateString isEqual:[NSNull null]]) {
        return nil;
    }
    return [DateUtils iso8601StringToDate:dateString];
}

- (void) setPreferredEtaStart:(NSDate *)preferredEtaStart {
    _infoJson[@"preferredEtaStart"] = [DateUtils formatDateAsIso8601:preferredEtaStart];
}

- (NSDate *)preferredEtaEnd {
    NSString *dateString = self.infoJson[@"preferredEtaEnd"];
    if ([dateString isEqual:[NSNull null]]) {
        return nil;
    }
    return [DateUtils iso8601StringToDate:dateString];
}

- (void) setPreferredEtaEnd:(NSDate *)preferredEtaEnd {
    _infoJson[@"preferredEtaEnd"] = [DateUtils formatDateAsIso8601:preferredEtaEnd];
}

- (NSNumber *)stayDurationInSeconds {
    NSNumber *val = _infoJson[@"stayDuration"];
    return val;
}

- (void) setStayDurationInSeconds:(NSNumber *)stayDuration {
    _infoJson[@"stayDuration"] = stayDuration;
}

- (NSNumber *)budget {
    NSNumber *val = _infoJson[@"budget"];
    if ([val isEqual:[NSNull null]]) {
        return nil;
    }
    return val;
}

- (void) setBudget:(NSNumber *)budget {
    _infoJson[@"budget"] = budget;
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
                      stayDuration:(NSNumber *)stayDuration
                            budget:(NSNumber *)budget {
    self = [super init];
    
    if (self) {
        NSString *etaStart = [preferredEtaStart isEqual:[NSNull null]] ? [NSNull null] : [DateUtils formatDateAsIso8601:preferredEtaStart];
        NSString *etaEnd = [preferredEtaEnd isEqual:[NSNull null]] ? [NSNull null] : [DateUtils formatDateAsIso8601:preferredEtaEnd];
        NSDictionary *newDict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:etaStart, etaEnd, stayDuration, budget, nil] forKeys:[NSArray arrayWithObjects:@"preferredEtaStart", @"preferredEtaEnd", @"stayDuration", @"budget", nil]];
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
    if ([self.stayDurationInSeconds intValue] < 0) {
        return NO;
    }
    return YES;
}

@end
