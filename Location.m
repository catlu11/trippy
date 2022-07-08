//
//  Location.m
//  Trippy
//
//  Created by Catherine Lu on 7/6/22.
//

#import "Location.h"
@import GooglePlaces;

@implementation Location

- (instancetype) initWithParams:(NSString *)title snippet:(NSString *)snippet latitude:(double)latitude longitude:(double)longitude user:(NSString *)user placeId:(NSString *)placeId objectId:(NSString *)objectId{
    self = [super init];
    
    if (self) {
        self.title = title;
        self.snippet = snippet;
        self.coord = CLLocationCoordinate2DMake(latitude, longitude);
        self.userId = user;
        self.placeId = placeId;
        self.objectId = objectId;
    }
    
    return self;
}

- (instancetype) initWithPlace:(GMSPlace *)place user:(NSString *)user {
    self = [super init];
    
    if (self) {
        self.title = place.name;
        self.snippet = place.description;
        self.coord = place.coordinate;
        self.userId = user;
        self.placeId = place.placeID;
    }
    
    return self;
}

@end
