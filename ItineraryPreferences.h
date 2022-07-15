//
//  ItineraryItemPreferences.h
//  Trippy
//
//  Created by Catherine Lu on 7/13/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ItineraryPreferences : NSObject
@property (strong, nonatomic) NSDate *preferredETA;
@property (strong, nonatomic) NSDate *preferredTOD;
@property (assign, nonatomic) NSNumber *stayDuration; // in seconds

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithAttributes:(NSDate * _Nullable)preferredEta
                            preferredTOD:(NSDate * _Nullable)preferredTod
                            stayDuration:(NSNumber *)stayDuration;
- (void)reinitialize:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;
- (BOOL) isValid;
@end

NS_ASSUME_NONNULL_END
