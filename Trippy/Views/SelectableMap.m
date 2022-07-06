//
//  SelectableMap.m
//  Trippy
//
//  Created by Catherine Lu on 7/6/22.
//

#import "SelectableMap.h"
#import "Location.h"
@import GoogleMaps;
@import GooglePlaces;

@interface SelectableMap ()
@property (strong, nonatomic) GMSMapView *mapView;
@end

@implementation SelectableMap

- (void) initWithCenter:(Location *)location {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.latitude
                                                          longitude:location.longitude
                                                               zoom:16];
    GMSMapView *map = [GMSMapView mapWithFrame:self.frame camera:camera];
    map.myLocationEnabled = YES;
    
    map.frame = self.bounds;
    self.mapView = map;
    [self addSubview:map];
}

- (void) addMarker:(Location *)location {
    GMSMarker *marker = [[GMSMarker alloc] init];

    marker.position = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    marker.title = location.title;
    marker.snippet = location.snippet;
    marker.map = self.mapView;
}

@end
