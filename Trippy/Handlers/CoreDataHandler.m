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
//    NSManagedObjectContext *moc = [self getContext];
//    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
//    NSBatchDeleteRequest *request = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
//    request.resultType = NSBatchDeleteResultTypeObjectIDs;
//
//    NSError *error = nil;
//    NSBatchDeleteResult *deleteResult = [moc executeRequest:request error:&error];
//    if (error) {
//        NSAssert(NO, @"Error deleting entity: %@\n%@", [error localizedDescription], [error userInfo]);
//    }
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
        [obj setValue:UIImagePNGRepresentation([MapUtils getStaticMapImage:loc.coord width:100 height:100]) forKey:@"staticMap"];
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
        if (col.parseObjectId) {
            [obj setValue:col.parseObjectId forKey:@"parseObjectId"];
            [obj setValue:[NSNumber numberWithBool:YES] forKey:@"synced"];
        } else {
            [obj setValue:[NSNumber numberWithBool:NO] forKey:@"synced"];
        }
        for (Location *l in col.locations) {
            NSManagedObject *locMO = [CoreDataUtils managedObjectFromLocation:l];
            [[obj mutableSetValueForKey:@"locations"] addObject:locMO];
        }
    }
    NSError *error = nil;
    if ([moc save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    NSLog(@"Saved collections: %@", [obj valueForKey:@"parseObjectId"]);
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
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[it toRouteDictionary] options:0 error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [obj setValue:jsonString forKey:@"routeJson"];
        [obj setValue:[CoreDataUtils managedObjectFromLocation:it.originLocation] forKey:@"originLocation"];
        [obj setValue:[CoreDataUtils managedObjectFromCollection:it.sourceCollection] forKey:@"sourceCollection"];
        [obj setValue:[NSNumber numberWithBool:it.isFavorited] forKey:@"isFavorited"];
        [obj setValue:UIImagePNGRepresentation(it.staticMap) forKey:@"staticMap"];
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
    NSLog(@"fetching offline locations");
    for (NSManagedObject *obj in managedObjects) {
        [locs addObject:[CoreDataUtils locationFromManagedObject:obj]];
    }
    return locs;
}

- (NSArray *)fetchCollections {
    NSArray *managedObjects = [self fetchObjects:@"LocationCollection"];
    NSMutableArray *cols = [[NSMutableArray alloc] init];
    NSLog(@"fetching offline collections");
    for (NSManagedObject *obj in managedObjects) {
        [cols addObject:[CoreDataUtils collectionFromManagedObject:obj]];
    }
    NSLog(@"number of collections, %d", cols.count);
    return cols;
}

- (NSArray *)fetchItineraries {
    NSArray *managedObjects = [self fetchObjects:@"Itinerary"];
    NSMutableArray *its = [[NSMutableArray alloc] init];
    NSLog(@"fetching offline itineraries");
    for (NSManagedObject *obj in managedObjects) {
        [its addObject:[CoreDataUtils itineraryFromManagedObject:obj]];
        NSLog(@"%@", [obj valueForKey:@"parseObjectId"]);
    }
    return its;
}

- (void)updateItinerary:(Itinerary *)it {
    NSManagedObjectContext *moc = [self getContext];
    NSManagedObject *obj = [CoreDataUtils managedObjectFromItinerary:it];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[it toRouteDictionary] options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [obj setValue:jsonString forKey:@"routeJson"];
    [obj setValue:[NSNumber numberWithBool:it.isFavorited] forKey:@"isFavorited"];
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

@end
