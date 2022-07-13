//
//  Location.m
//  Trippy
//
//  Created by Catherine Lu on 7/6/22.
//

#import "Location.h"
#import "Parse/Parse.h"
#import "ParseUtils.h"
@import GooglePlaces;

@interface Location ()
@property (strong, nonatomic) PFObject *obj;
@end

@implementation Location

/* Custom getters and setters */

- (NSString*)title {
    return _obj[@"title"];
}

- (void)setTitle:(NSString*)title {
    _obj[@"title"] = title;
}

- (NSString*)placeId {
    return _obj[@"placeId"];
}

- (void)setPlaceId:(NSString*)placeId {
    _obj[@"placeId"] = placeId;
}

- (NSString*)snippet {
    return _obj[@"snippet"];
}

- (void)setSnippet:(NSString*)snippet {
    _obj[@"snippet"] = snippet;
}

- (NSString*)parseObjectId {
    return _obj.objectId;
}

- (CLLocationCoordinate2D)coord {
    PFGeoPoint *point = _obj[@"coord"];
    return CLLocationCoordinate2DMake(point.latitude, point.longitude);
}

- (void)setCoord:(CLLocationCoordinate2D)coord {
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:coord.latitude longitude:coord.longitude];
    _obj[@"coord"] = point;
}

- (instancetype) initWithPFObj:(PFObject *)obj {
    self = [super init];
    if (self) {
        self.obj = obj;
    }
    return self;
}

- (instancetype) initWithPlace:(GMSPlace *)place {
    self = [super init];
    
    if (self) {
        PFObject *obj = [PFObject objectWithClassName:@"Location"];
        obj[@"placeId"] = place.placeID;
        obj[@"title"] = place.name;
        obj[@"snippet"] = place.description;
        obj[@"coord"] = [PFGeoPoint geoPointWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude];
        obj[@"createdBy"] = [PFUser currentUser];
        self.obj = obj;
    }
    
    return self;
}

- (PFObject *)getPfObjRepresentation {
    return self.obj;
}

@end
