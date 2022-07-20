//
//  ItineraryItemPreferences.h
//  Trippy
//
//  Created by Catherine Lu on 7/13/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WaypointPreferences : NSObject
@property (strong, nonatomic) NSDate *preferredEtaStart;
@property (strong, nonatomic) NSDate *preferredEtaEnd;
@property (assign, nonatomic) NSNumber *stayDurationInSeconds;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithAttributes:(NSDate * _Nullable)preferredEtaStart
                   preferredEtaEnd:(NSDate * _Nullable)preferredEtaEnd
                            stayDuration:(NSNumber *)stayDuration;
- (void)reinitialize:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;
- (BOOL) isValid;
@end

NS_ASSUME_NONNULL_END
