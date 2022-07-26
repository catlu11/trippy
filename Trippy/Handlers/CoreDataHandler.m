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

- (void)clearEntity:(NSString *)entityName {
    NSManagedObjectContext *moc = [self getContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSBatchDeleteRequest *request = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
    request.resultType = NSBatchDeleteResultTypeObjectIDs;

    NSError *error = nil;
    NSBatchDeleteResult *deleteResult = [moc executeRequest:request error:&error];
    if (error) {
        NSAssert(NO, @"Error deleting entity: %@\n%@", [error localizedDescription], [error userInfo]);
    } else {
        NSManagedObjectID *objectIds = deleteResult.result;
        [NSManagedObjectContext mergeChangesFromRemoteContextSave:@{NSDeletedObjectsKey: objectIds} intoContexts:@[moc]];
    }
}

- (void)saveNewLocation:(Location *)loc {
    NSManagedObjectContext *moc = [self getContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:moc];
    NSManagedObject *obj = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:moc];
    [obj setValue:loc.title forKey:@"title"];
    [obj setValue:loc.snippet forKey:@"snippet"];
    [obj setValue:UIImagePNGRepresentation([MapUtils getStaticMapImage:loc.coord width:100 height:100]) forKey:@"staticMap"];
    if (loc.parseObjectId) {
        [obj setValue:loc.parseObjectId forKey:@"parseObjectId"];
        [obj setValue:[NSNumber numberWithBool:YES] forKey:@"synced"];
    } else {
        [obj setValue:[NSNumber numberWithBool:NO] forKey:@"synced"];
    }
    NSError *error = nil;
    if ([moc save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

- (void)saveNewCollection:(LocationCollection *)col {
    NSManagedObjectContext *moc = [self getContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocationCollection" inManagedObjectContext:moc];
    NSManagedObject *obj = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:moc];
    [obj setValue:col.title forKey:@"title"];
    [obj setValue:col.snippet forKey:@"snippet"];
    [obj setValue:col.createdAt forKey:@"createdAt"];
    if (col.locations.count > 0) {
        Location *loc = col.locations[0];
        [obj setValue:UIImagePNGRepresentation(loc.staticMap) forKey:@"staticMap"];
    }
    if (col.parseObjectId) {
        [obj setValue:col.parseObjectId forKey:@"parseObjectId"];
        [obj setValue:[NSNumber numberWithBool:YES] forKey:@"synced"];
    } else {
        [obj setValue:[NSNumber numberWithBool:NO] forKey:@"synced"];
    }
    for (Location *l in col.locations) {
        [[obj mutableSetValueForKey:@"locations"] addObject:[CoreDataUtils managedObjectFromLocation:l]];
    }
    NSError *error = nil;
    if ([moc save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

- (void)saveNewItinerary:(Itinerary *)it {
    // TODO: Implement
}

- (NSArray *)fetchObjects:(NSString *)entityName {
    NSManagedObjectContext *moc = [self getContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
     
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    if (!results) {
        NSLog(@"Error fetching Location objects: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    return results;
}

@end
