//
//  CoreDataUtils.m
//  Trippy
//
//  Created by Catherine Lu on 7/26/22.
//

#import "CoreDataUtils.h"
#import "Location.h"
@import CoreData;

@implementation CoreDataUtils

+ (Location *)locationFromManagedObject:(NSManagedObject *)obj {
    Location *loc = [[Location alloc] init];
    loc.title = [obj valueForKey:@"title"];
    loc.snippet = [obj valueForKey:@"snippet"];
    loc.staticMap = [UIImage imageWithData:[obj valueForKey:@"staticMap"]];
    return loc;
}

@end
