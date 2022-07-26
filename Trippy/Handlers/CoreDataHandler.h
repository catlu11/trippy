//
//  CoreDataHandler.h
//  Trippy
//
//  Created by Catherine Lu on 7/25/22.
//

#import <Foundation/Foundation.h>
@class Location;

NS_ASSUME_NONNULL_BEGIN

@interface CoreDataHandler : NSObject
+ (CoreDataHandler *)shared;
- (void)clearEntity:(NSString *)entityName;
- (void)saveNewLocation:(Location *)loc;
- (void)saveNewCollection:(LocationCollection *)col;
- (void)saveNewItinerary:(Itinerary *)it;
- (NSArray *)fetchObjects:(NSString *)entityName;
@end

NS_ASSUME_NONNULL_END
