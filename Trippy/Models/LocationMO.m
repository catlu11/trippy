//
//  LocationMO.m
//  Trippy
//
//  Created by Catherine Lu on 7/25/22.
//

#import "LocationMO.h"

@implementation LocationMO

- (void)awakeFromFetch {
    [super awakeFromFetch];
    NSLog(@"fetched a Location MO");
}

- (void)didSave {
    NSLog(@"did save a Location MO");
}

@end
