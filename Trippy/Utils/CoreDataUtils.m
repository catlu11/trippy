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
    if ([obj valueForKey:@"synced"]) {
        loc.parseObjectId = [obj valueForKey:@"parseObjectId"];
    }
    return loc;
}

+ (LocationCollection *)collectionFromManagedObject:(NSManagedObject *)obj {
    // TODO: Implement
    return nil;
}

+ (Itinerary *)itineraryFromManagedObject:(NSManagedObject *)obj {
    // TODO: Implement
    return nil;
}

+ (NSManagedObject *)managedObjectFromLocation:(Location *)loc {
    // TODO: Implement
    return nil;
}

+ (NSManagedObject *)managedObjectFromCollection:(LocationCollection *)col {
    // TODO: Implement
    return nil;
}

+ (NSManagedObject *)managedObjectFromItinerary:(Itinerary *)it {
    // TODO: Implement
    return nil;
}

@end
