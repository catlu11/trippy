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
- (void)reinitialize:(NSDictionary *)dict;
+ (NSDictionary *)prefDictFromAttributes:(NSDate * _Nullable)preferredETA
                            preferredTOD:(NSDate * _Nullable)preferredTOD
                            stayDuration:(NSTimeInterval * _Nullable)stayDuration;
- (NSDictionary *)toDictionary;
@end

NS_ASSUME_NONNULL_END
