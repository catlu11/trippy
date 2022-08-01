//
//  CoreDataUtils.m
//  Trippy
//
//  Created by Catherine Lu on 7/26/22.
//

#import "CoreDataUtils.h"
#import "Location.h"
#import "LocationCollection.h"
#import "Itinerary.h"
#import "CoreDataHandler.h"
@import CoreData;

@implementation CoreDataUtils

+ (Location *)locationFromManagedObject:(NSManagedObject *)obj {
    Location *loc = [[Location alloc] init];
    loc.title = [obj valueForKey:@"title"];
    loc.snippet = [obj valueForKey:@"snippet"];
    loc.staticMap = [UIImage imageWithData:[obj valueForKey:@"staticMap"]];
    loc.parseObjectId = [obj valueForKey:@"parseObjectId"];
    return loc;
}

+ (LocationCollection *)collectionFromManagedObject:(NSManagedObject *)obj {
    LocationCollection *col = [[LocationCollection alloc] init];
    col.title = [obj valueForKey:@"title"];
    col.snippet = [obj valueForKey:@"snippet"];
    col.parseObjectId = [obj valueForKey:@"parseObjectId"];
    NSArray *locRelation = [[obj valueForKey:@"locations"] allObjects];
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    for (NSManagedObject *locObj in locRelation) {
        [locations addObject:[self locationFromManagedObject:locObj]];
    }
    col.locations = locations;
    col.createdAt = [obj valueForKey:@"createdAt"];
    return col;
}

+ (Itinerary *)itineraryFromManagedObject:(NSManagedObject *)obj {
    NSData *routeData = [[obj valueForKey:@"routeJson"] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *routeJson = [NSJSONSerialization JSONObjectWithData:routeData
                                                                 options:kNilOptions
                                                                   error:nil];
    NSData *prefData = [[obj valueForKey:@"prefJson"] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *prefJson = [NSJSONSerialization JSONObjectWithData:prefData
                                                                 options:kNilOptions
                                                                   error:nil];
    Location *originLocation = [self locationFromManagedObject:[obj valueForKey:@"originLocation"]];
    LocationCollection *sourceCollection = [self collectionFromManagedObject:[obj valueForKey:@"sourceCollection"]];
    Itinerary *it = [[Itinerary alloc] initWithDictionary:routeJson
                                                  prefJson:prefJson
                                                 departure:[obj valueForKey:@"departureDate"]
                                         mileageConstraint:[obj valueForKey:@"mileageConstraint"]
                                          budgetConstraint:[obj valueForKey:@"budgetConstraint"]
                                          sourceCollection:sourceCollection
                                            originLocation:originLocation
                                                      name:[obj valueForKey:@"name"]
                                               isFavorited:[[obj valueForKey:@"isFavorited"] boolValue]];
    it.staticMap = [UIImage imageWithData:[obj valueForKey:@"staticMap"]];
    it.parseObjectId = [obj valueForKey:@"parseObjectId"];
    return it;
}

+ (NSManagedObject *)managedObjectFromLocation:(Location *)loc {
    return [[CoreDataHandler shared] saveLocation:loc];
}

+ (NSManagedObject *)managedObjectFromCollection:(LocationCollection *)col {
    return [[CoreDataHandler shared] saveCollection:col];
}

+ (NSManagedObject *)managedObjectFromItinerary:(Itinerary *)it {
    return [[CoreDataHandler shared] saveItinerary:it];
}

@end
