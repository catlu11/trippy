//
//  SelectableMap.m
//  Trippy
//
//  Created by Catherine Lu on 7/6/22.
//

#import "SelectableMap.h"
#import "Location.h"
#import "MapUtils.h"
@import GooglePlaces;

@interface SelectableMap ()
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) NSMutableArray *markersArray;
@end

@implementation SelectableMap

- (void) initWithCenter:(CLLocationCoordinate2D)location {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.latitude
                                                          longitude:location.longitude
                                                               zoom:DEFAULT_ZOOM];
    GMSMapView *map = [GMSMapView mapWithFrame:self.frame camera:camera];
    map.myLocationEnabled = YES;
    
    map.frame = self.bounds;
    self.mapView = map;
    [self addSubview:map];
}

- (void) initWithBounds:(GMSCoordinateBounds *)bounds {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:0
                                                          longitude:0
                                                               zoom:DEFAULT_ZOOM];
    GMSMapView *map = [GMSMapView mapWithFrame:self.frame camera:camera];
    [map animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:60.0f]];
    map.myLocationEnabled = YES;
    
    map.frame = self.bounds;
    self.mapView = map;
    [self addSubview:map];
}

- (void) addMarker:(Location *)location {
    GMSMarker *marker = [[GMSMarker alloc] init];

    marker.position = location.coord;
    marker.title = location.title;
    marker.snippet = location.snippet;
    marker.map = self.mapView;
    
    [self.markersArray addObject:marker];
}

- (void) addPolyline:(NSString *)polyline {
    GMSPath *path = [GMSPath pathFromEncodedPath:polyline];
    GMSPolyline *line = [GMSPolyline polylineWithPath:path];
    line.strokeColor = [UIColor systemBlueColor];
    line.strokeWidth = 5.0;
    line.map = self.mapView;
}

- (void) clearMarkers {
    for(GMSMarker *marker in self.markersArray) {
        marker.map = nil;
    }
    self.markersArray = [[NSMutableArray alloc] init];
}

- (void) setCameraToLoc:(CLLocationCoordinate2D)location animate:(BOOL)animate {
    GMSCameraPosition *pos = [GMSCameraPosition cameraWithLatitude:location.latitude longitude:location.longitude zoom:DEFAULT_ZOOM];
    if(animate) {
        [self.mapView animateToCameraPosition:pos];
    }
    else {
        [self.mapView setCamera:pos];
    }
}

- (CLLocationCoordinate2D) getCenter {
    CGPoint point = self.mapView.center;
    return [self.mapView.projection coordinateForPoint:point];
}

@end
