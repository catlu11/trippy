//
//  Location.m
//  Trippy
//
//  Created by Catherine Lu on 7/6/22.
//

#import "Location.h"
#import "MapUtils.h"
@import GooglePlaces;

@implementation Location

- (instancetype) initWithParams:(NSString *)title
                        snippet:(NSString *)snippet
                       latitude:(double)latitude
                      longitude:(double)longitude
                           user:(NSString *)user
                        placeId:(NSString *)placeId
                          types:(NSArray *)types
                     priceLevel:(NSNumber *)priceLevel
                  parseObjectId:(NSString *)parseObjectId {
    self = [super init];
    
    if (self) {
        self.title = title;
        self.snippet = snippet;
        self.coord = CLLocationCoordinate2DMake(latitude, longitude);
        self.userId = user;
        self.placeId = placeId;
        self.types = types;
        self.priceLevel = priceLevel;
        self.parseObjectId = parseObjectId;
        self.staticMap = [MapUtils getStaticMapImage:self.coord width:100 height:100];
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
        self.types = place.types;
        self.priceLevel = @(place.priceLevel);
        self.placeId = place.placeID;
    }
    
    return self;
}

@end
