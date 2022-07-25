//
//  CoreDataHandler.m
//  Trippy
//
//  Created by Catherine Lu on 7/25/22.
//

#import "CoreDataHandler.h"
#import "AppDelegate.h"
#import "LocationMO.h"
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

- (void)saveLocation {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:[self getContext]];
    LocationMO *obj = [[LocationMO alloc] initWithEntity:entity insertIntoManagedObjectContext:[self getContext]];
    [[self getContext] save:nil];
}

- (void)fetchLocation {
    
}

@end
