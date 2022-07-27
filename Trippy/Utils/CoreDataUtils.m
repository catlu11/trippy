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
    if ([obj valueForKey:@"synced"]) {
        loc.parseObjectId = [obj valueForKey:@"parseObjectId"];
    }
    return loc;
}

+ (LocationCollection *)collectionFromManagedObject:(NSManagedObject *)obj {
    LocationCollection *col = [[LocationCollection alloc] init];
    col.title = [obj valueForKey:@"title"];
    col.snippet = [obj valueForKey:@"snippet"];
    if ([obj valueForKey:@"synced"]) {
        col.parseObjectId = [obj valueForKey:@"parseObjectId"];
    }
    NSSet *locRelation = [obj valueForKey:@"locations"];
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    for (NSManagedObject *locObj in locRelation) {
        [locations addObject:[self locationFromManagedObject:locObj]];
    }
    col.locations = locations;
    col.createdAt = [obj valueForKey:@"createdAt"];
    return col;
}

+ (Itinerary *)itineraryFromManagedObject:(NSManagedObject *)obj {
    NSData *data = [[obj valueForKey:@"routeJson"] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:nil];
    Location *originLocation = [self locationFromManagedObject:[obj valueForKey:@"originLocation"]];
    LocationCollection *sourceCollection = [self collectionFromManagedObject:[obj valueForKey:@"sourceCollection"]];
    Itinerary *it = [[Itinerary alloc] initWithDictionary:jsonResponse
                                                  prefJson:nil
                                                 departure:nil
                                         mileageConstraint:nil
                                          budgetConstraint:nil
                                          sourceCollection:sourceCollection
                                            originLocation:originLocation
                                                      name:[obj valueForKey:@"name"]
                                               isFavorited:[[obj valueForKey:@"isFavorited"] boolValue]];
    it.staticMap = [UIImage imageWithData:[obj valueForKey:@"staticMap"]];
    if ([obj valueForKey:@"synced"]) {
        it.parseObjectId = [obj valueForKey:@"parseObjectId"];
    }
    return it;
}

+ (NSManagedObject *)managedObjectFromLocation:(Location *)loc {
    NSManagedObject *obj = [[CoreDataHandler shared] getEntityById:@"Location" parseObjectId:loc.parseObjectId];
    if (obj) {
        return obj;
    }
    return [[CoreDataHandler shared] saveNewLocation:loc];
}

+ (NSManagedObject *)managedObjectFromCollection:(LocationCollection *)col {
    NSManagedObject *obj = [[CoreDataHandler shared] getEntityById:@"LocationCollection" parseObjectId:col.parseObjectId];
    if (obj) {
        return obj;
    }
    return [[CoreDataHandler shared] saveNewCollection:col];
}

+ (NSManagedObject *)managedObjectFromItinerary:(Itinerary *)it {
    NSManagedObject *obj = [[CoreDataHandler shared] getEntityById:@"Itinerary" parseObjectId:it.parseObjectId];
    if (obj) {
        return obj;
    }
    return [[CoreDataHandler shared] saveNewItinerary:it];
}

@end
