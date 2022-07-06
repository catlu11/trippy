//
//  Location.m
//  Trippy
//
//  Created by Catherine Lu on 7/6/22.
//

#import "Location.h"
@import GooglePlaces;

@implementation Location

- (instancetype) initWithParams:(NSString *)title snippet:(NSString *)snippet latitude:(double)latitude longitude:(double)longitude {
    self = [super init];
    
    if (self) {
        self.title = title;
        self.snippet = snippet;
        self.coord = CLLocationCoordinate2DMake(latitude, longitude);
    }
    
    return self;
}

- (instancetype) initWithPlace:(GMSPlace *)place {
    self = [super init];
    
    if (self) {
        self.title = place.name;
        self.snippet = place.description;
        self.coord = place.coordinate;
    }
    
    return self;
}

@end
