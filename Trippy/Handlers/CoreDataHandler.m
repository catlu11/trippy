//
//  CoreDataHandler.m
//  Trippy
//
//  Created by Catherine Lu on 7/25/22.
//

#import "CoreDataHandler.h"
#import "AppDelegate.h"
#import "Location.h"
#import "MapUtils.h"
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
        NSAssert(NO, @"Error deleting Locations: %@\n%@", [error localizedDescription], [error userInfo]);
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
    
    NSError *error = nil;
    if ([moc save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

- (NSArray *)fetchLocations {
    NSManagedObjectContext *moc = [self getContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
     
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    if (!results) {
        NSLog(@"Error fetching Location objects: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    return results;
}

@end
