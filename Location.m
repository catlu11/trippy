//
//  Location.m
//  Trippy
//
//  Created by Catherine Lu on 7/6/22.
//

#import "Location.h"

@implementation Location

- (instancetype) initWithParams:(NSString *)title snippet:(NSString *)snippet latitude:(double)latitude longitude:(double)longitude {
    self = [super init];
    
    if (self) {
        self.title = title;
        self.snippet = snippet;
        self.latitude = latitude;
        self.longitude = longitude;
    }
    
    return self;
}

@end
