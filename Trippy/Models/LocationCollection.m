//
//  Collection.m
//  Trippy
//
//  Created by Catherine Lu on 7/7/22.
//

#import "LocationCollection.h"
#import "Parse/Parse.h"
#import "ParseUtils.h"
#import "Location.h"

@interface LocationCollection ()
@property (strong, nonatomic) PFObject *obj;
@property (strong, nonatomic) NSMutableArray *locationsArray;
@end

@implementation LocationCollection

/* Custom getters and setters */

- (NSString *)title {
    return _obj[@"title"];
}

- (void)setTitle:(NSString*)title {
    _obj[@"title"] = title;
}

- (NSString*)snippet {
    return _obj[@"snippet"];
}

- (void)setSnippet:(NSString*)snippet {
    _obj[@"snippet"] = snippet;
}

- (NSArray *)locations {
    return _locationsArray;
}

- (NSDate *)createdAt {
    return _obj[@"createdAt"];
}

- (NSString *)parseObjectId {
    return _obj.objectId;
}

- (void)addLocation:(Location *)location {
    if (location.parseObjectId != nil) {
        PFRelation *relation = [_obj relationForKey:@"locations"];
        [relation addObject:[location getPfObjRepresentation]];
        [_locationsArray addObject:location];
    }
}

- (void)removeLocation:(Location *)location {
    if (location.parseObjectId != nil) {
        PFRelation *relation = [_obj relationForKey:@"locations"];
        [relation removeObject:[location getPfObjRepresentation]];
        [_locationsArray removeObject:location];
    }
}

+ (void)initFromPFObj:(PFObject *)obj completion:(void (^)(LocationCollection *col, NSError *error))completion {
    LocationCollection *col = [[LocationCollection alloc] init];
    col.locationsArray = [[NSMutableArray alloc] init];
    col.obj = obj;
    PFRelation *relation = [obj relationForKey:@"locations"];
    PFQuery *locationsQuery = [relation query];
    [locationsQuery orderByDescending:@"createdAt"];
    [locationsQuery includeKeys:[ParseUtils getLocationKeys]];
    [locationsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            completion(nil, error);
        } else {
            for (PFObject *loc in objects) {
                [col addLocation:[[Location alloc] initWithPFObj:loc]];
            }
            completion(col, nil);
        }
    }];
}

- (instancetype) initWithParams:(NSArray *)locations
                          title:(NSString*)title
                        snippet:(NSString*)snippet {
    self = [super init];
    
    if (self) {
        self.locationsArray = [[NSMutableArray alloc] init];
        PFObject *obj = [PFObject objectWithClassName:@"Collection"];
        obj[@"title"] = title;
        obj[@"snippet"] = snippet;
        PFRelation *relation = [obj relationForKey:@"locations"];
        for (Location *loc in locations) {
            if (loc.parseObjectId != nil) {
                [relation addObject:[loc getPfObjRepresentation]];
            }
        }
        self.obj = obj;
    }
    
    return self;
}

- (PFObject *)getPfObjRepresentation {
    return self.obj;
}

@end
