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

- (void) setPreferredETA:(NSDate *)preferredETA {
    _infoJson[@"preferredETA"] = [DateUtils formatDateAsISO8601:preferredETA];
}

- (NSDate *)preferredTOD {
    NSString *dateString = self.infoJson[@"preferredTOD"];
    if ([dateString isEqual:[NSNull null]]) {
        return nil;
    }
    return [DateUtils isoStringToDate:dateString];
}

- (void) setPreferredTOD:(NSDate *)preferredTOD {
    _infoJson[@"preferredTOD"] = [DateUtils formatDateAsISO8601:preferredTOD];
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

+ (NSDictionary *)prefDictFromAttributes:(NSDate * _Nullable)preferredETA
                            preferredTOD:(NSDate * _Nullable)preferredTOD
                            stayDuration:(NSTimeInterval * _Nullable)stayDuration {
    NSDictionary *newDict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:preferredETA, preferredTOD, stayDuration, nil] forKeys:[NSArray arrayWithObjects:@"preferredEta", @"preferredTOD", @"stayDuration", nil]];
    return newDict;
}

- (NSDictionary *)toDictionary {
    return self.infoJson;
}

@end
