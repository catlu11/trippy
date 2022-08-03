//
//  CoreDataHandler.m
//  Trippy
//
//  Created by Catherine Lu on 7/25/22.
//

#import "CoreDataHandler.h"
#import "AppDelegate.h"
#import "Location.h"
#import "LocationCollection.h"
#import "Itinerary.h"
#import "MapUtils.h"
#import "CoreDataUtils.h"
@import CoreData;

@implementation CoreDataHandler

+ (CoreDataHandler *)shared {
    static CoreDataHandler *_sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}

- (NSManagedObjectContext *)getContext {
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return ad.managedObjectContext;
}

- (NSManagedObject *)getEntityById:(NSString *)entity parseObjectId:(NSString *)parseObjectId {
    NSManagedObjectContext *moc = [self getContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parseObjectId == %@", parseObjectId];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    if (!results) {
        NSLog(@"Error fetching entity object: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    if (results.count == 0) {
        return nil;
    }
    return [results firstObject];
}

- (void)clearEntity:(NSString *)entityName {
    NSArray *objects = [self fetchObjects:entityName];
    NSManagedObjectContext *moc = [self getContext];
    for (NSManagedObject *obj in objects) {
        if ([entityName isEqualToString:@"LocationCollection"] || [entityName isEqualToString:@"Location"]) {
            int numDependents = [[obj valueForKey:@"dependents"] intValue];
            if (numDependents > 0) {
                continue;
            }
        }
        [moc deleteObject:obj];
    }
    NSError *error = nil;
    if ([moc save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

- (NSManagedObject *)saveLocation:(Location *)loc {
    NSManagedObjectContext *moc = [self getContext];
    NSManagedObject *cacheObj = [[CoreDataHandler shared] getEntityById:@"Location" parseObjectId:loc.parseObjectId];
    NSManagedObject *obj;
    if (cacheObj) {
        obj = cacheObj;
    } else {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:moc];
        obj = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:moc];
        [obj setValue:loc.title forKey:@"title"];
        [obj setValue:loc.snippet forKey:@"snippet"];
        [obj setValue:loc.placeId forKey:@"placeId"];
        [obj setValue:UIImagePNGRepresentation([MapUtils getStaticMapImage:loc.coord width:100 height:100]) forKey:@"staticMap"];
        [obj setValue:@(0) forKey:@"dependents"];
        if (loc.parseObjectId) {
            [obj setValue:loc.parseObjectId forKey:@"parseObjectId"];
            [obj setValue:[NSNumber numberWithBool:YES] forKey:@"synced"];
        } else {
            [obj setValue:[NSNumber numberWithBool:NO] forKey:@"synced"];
        }
    }
    NSError *error = nil;
    if ([moc save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    return obj;
}

- (NSManagedObject *)saveCollection:(LocationCollection *)col {
    NSManagedObjectContext *moc = [self getContext];
    NSManagedObject *cacheObj = [[CoreDataHandler shared] getEntityById:@"LocationCollection" parseObjectId:col.parseObjectId];
    NSManagedObject *obj;
    if (cacheObj) {
        obj = cacheObj;
    } else {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocationCollection" inManagedObjectContext:moc];
        obj = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:moc];
        [obj setValue:col.title forKey:@"title"];
        [obj setValue:col.snippet forKey:@"snippet"];
        [obj setValue:col.createdAt forKey:@"createdAt"];
        [obj setValue:@(0) forKey:@"dependents"];
        if (col.parseObjectId) {
            [obj setValue:col.parseObjectId forKey:@"parseObjectId"];
            [obj setValue:[NSNumber numberWithBool:YES] forKey:@"synced"];
        } else {
            [obj setValue:[NSNumber numberWithBool:NO] forKey:@"synced"];
        }
        for (Location *l in col.locations) {
            NSManagedObject *locMO = [CoreDataUtils managedObjectFromLocation:l];
            [[obj mutableSetValueForKey:@"locations"] addObject:locMO];
            int newDependents = [[locMO valueForKey:@"dependents"] intValue] + 1;
            [locMO setValue:@(newDependents) forKey:@"dependents"];
        }
    }
    NSError *error = nil;
    if ([moc save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    return obj;
}

- (NSManagedObject *)saveItinerary:(Itinerary *)it {
    NSManagedObjectContext *moc = [self getContext];
    NSManagedObject *cacheObj = [[CoreDataHandler shared] getEntityById:@"Itinerary" parseObjectId:it.parseObjectId];
    NSManagedObject *obj;
    if (cacheObj) {
        obj = cacheObj;
    } else {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Itinerary" inManagedObjectContext:moc];
        obj = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:moc];
        [obj setValue:it.name forKey:@"name"];
        if (it.parseObjectId) {
            [obj setValue:it.parseObjectId forKey:@"parseObjectId"];
            [obj setValue:[NSNumber numberWithBool:YES] forKey:@"synced"];
        } else {
            [obj setValue:[NSNumber numberWithBool:NO] forKey:@"synced"];
        }
        NSData *routeJsonData = [NSJSONSerialization dataWithJSONObject:[it toRouteDictionary] options:0 error:nil];
        NSString *routeJsonString = [[NSString alloc] initWithData:routeJsonData encoding:NSUTF8StringEncoding];
        [obj setValue:routeJsonString forKey:@"routeJson"];
        NSData *prefJsonData = [NSJSONSerialization dataWithJSONObject:[it toPrefsDictionary] options:0 error:nil];
        NSString *prefJsonString = [[NSString alloc] initWithData:prefJsonData encoding:NSUTF8StringEncoding];
        [obj setValue:prefJsonString forKey:@"prefJson"];
        NSManagedObject *originLoc = [CoreDataUtils managedObjectFromLocation:it.originLocation];
        NSManagedObject *originCol = [CoreDataUtils managedObjectFromCollection:it.sourceCollection];
        int newDependentsLoc = [[originLoc valueForKey:@"dependents"] intValue] + 1;
        int newDependentsCol = [[originCol valueForKey:@"dependents"] intValue] + 1;
        [originLoc setValue:@(newDependentsLoc) forKey:@"dependents"];
        [originCol setValue:@(newDependentsCol) forKey:@"dependents"];
        [obj setValue:originLoc forKey:@"originLocation"];
        [obj setValue:originCol forKey:@"sourceCollection"];
        [obj setValue:[NSNumber numberWithBool:it.isFavorited] forKey:@"isFavorited"];
        [obj setValue:UIImagePNGRepresentation(it.staticMap) forKey:@"staticMap"];
        [obj setValue:it.departureTime forKey:@"departureDate"];
        [obj setValue:it.budgetConstraint forKey:@"budgetConstraint"];
        [obj setValue:it.mileageConstraint forKey:@"mileageConstraint"];
    }
    NSError *error = nil;
    if ([moc save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    return obj;
}

- (NSArray *)fetchObjects:(NSString *)entityName {
    NSManagedObjectContext *moc = [self getContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    if (!results) {
        NSLog(@"Error fetching objects: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    return results;
}

- (NSArray *)fetchLocations {
    NSArray *managedObjects = [self fetchObjects:@"Location"];
    NSMutableArray *locs = [[NSMutableArray alloc] init];
    for (NSManagedObject *obj in managedObjects) {
        [locs addObject:[CoreDataUtils locationFromManagedObject:obj]];
    }
    return locs;
}

- (NSArray *)fetchCollections {
    NSArray *managedObjects = [self fetchObjects:@"LocationCollection"];
    NSMutableArray *cols = [[NSMutableArray alloc] init];
    for (NSManagedObject *obj in managedObjects) {
        [cols addObject:[CoreDataUtils collectionFromManagedObject:obj]];
    }
    return cols;
}

- (NSArray *)fetchItineraries {
    NSArray *managedObjects = [self fetchObjects:@"Itinerary"];
    NSMutableArray *its = [[NSMutableArray alloc] init];
    for (NSManagedObject *obj in managedObjects) {
        [its addObject:[CoreDataUtils itineraryFromManagedObject:obj]];
    }
    return its;
}

- (void)updateItinerary:(Itinerary *)it {
    NSManagedObjectContext *moc = [self getContext];
    NSManagedObject *obj = [CoreDataUtils managedObjectFromItinerary:it];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[it toRouteDictionary] options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [obj setValue:jsonString forKey:@"routeJson"];
    NSData *prefJsonData = [NSJSONSerialization dataWithJSONObject:[it toPrefsDictionary] options:0 error:nil];
    NSString *prefJsonString = [[NSString alloc] initWithData:prefJsonData encoding:NSUTF8StringEncoding];
    [obj setValue:prefJsonString forKey:@"prefJson"];
    [obj setValue:it.departureTime forKey:@"departureDate"];
    [obj setValue:it.budgetConstraint forKey:@"budgetConstraint"];
    [obj setValue:it.mileageConstraint forKey:@"mileageConstraint"];
    [obj setValue:[NSNumber numberWithBool:it.isFavorited] forKey:@"isFavorited"];
    [obj setValue:[NSNumber numberWithBool:NO] forKey:@"synced"];
    [obj setValue:UIImagePNGRepresentation(it.staticMap) forKey:@"staticMap"];
    NSError *error = nil;
    if ([moc save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

- (void)updateCollection:(LocationCollection *)col {
    NSManagedObjectContext *moc = [self getContext];
    NSManagedObject *obj = [CoreDataUtils managedObjectFromCollection:col];
    for (Location *l in col.locations) {
        [[obj mutableSetValueForKey:@"locations"] addObject:[CoreDataUtils managedObjectFromLocation:l]];
    }
    NSError *error = nil;
    if ([moc save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

- (NSArray *)fetchUnsyncedObjects:(NSString *)entityName {
    NSManagedObjectContext *moc = [self getContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"synced == NO"];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    if (!results) {
        NSLog(@"Error fetching objects: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    return results;
}

- (NSArray *)fetchUnsyncedCollections {
    NSArray *collections = [self fetchUnsyncedObjects:@"LocationCollection"];
    NSMutableArray *res = [[NSMutableArray alloc] init];
    for (NSManagedObject *col in collections) {
        LocationCollection *newCol = [CoreDataUtils collectionFromManagedObject:col];
        newCol.isOffline = YES;
        [res addObject:newCol];
    }
    return res;
}

- (NSArray *)fetchUnsyncedItineraries {
    NSArray *itineraries = [self fetchUnsyncedObjects:@"Itinerary"];
    NSMutableArray *res = [[NSMutableArray alloc] init];
    for (NSManagedObject *it in itineraries) {
        Itinerary *newIt = [CoreDataUtils itineraryFromManagedObject:it];
        newIt.isOffline = YES;
        [res addObject:newIt];
    }
    return res;
}

- (void)deleteUnsyncedCollections {
    NSManagedObjectContext *moc = [self getContext];
    NSArray *collections = [self fetchUnsyncedObjects:@"LocationCollection"];
    for (NSManagedObject *col in collections) {
        NSSet *locs = [col valueForKey:@"locations"];
        for (NSManagedObject *locObj in locs) {
            int updated = [[locObj valueForKey:@"dependents"] intValue] - 1;
            [locObj setValue:@(updated) forKey:@"dependents"];
        }
        [moc deleteObject:col];
    }
    NSError *error = nil;
    if ([moc save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

- (void)deleteUnsyncedItineraries {
    NSManagedObjectContext *moc = [self getContext];
    NSArray *itineraries = [self fetchUnsyncedObjects:@"Itinerary"];
    for (NSManagedObject *it in itineraries) {
        NSManagedObject *locObj = [it valueForKey:@"originLocation"];
        NSManagedObject *colObj = [it valueForKey:@"sourceCollection"];
        int updatedLoc = [[locObj valueForKey:@"dependents"] intValue] - 1;
        int updatedCol = [[colObj valueForKey:@"dependents"] intValue] - 1;
        [locObj setValue:@(updatedLoc) forKey:@"dependents"];
        [colObj setValue:@(updatedCol) forKey:@"dependents"];
        [moc deleteObject:it];
    }
    NSError *error = nil;
    if ([moc save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

@end
