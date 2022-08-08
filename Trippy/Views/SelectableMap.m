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

@interface SelectableMap () <GMSMapViewDelegate>
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) NSMutableArray *markersArray;
@property (strong, nonatomic) GMSPath *path;
@property (strong, nonatomic) GMSMutablePath *animatedPath;
@property (strong, nonatomic) GMSPolyline *animatedPolyline;
@property int curPathIndex;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation SelectableMap

- (void) initWithStaticImage:(UIImage *)image {
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImageView *newView = [[UIImageView alloc] init];
    newView.image = image;
    newView.frame = self.bounds;
    newView.contentMode = UIViewContentModeScaleAspectFill;
    [self insertSubview:newView atIndex:0];
    self.isEnabled = NO;
}

- (void) initWithCenter:(CLLocationCoordinate2D)location {
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.latitude
                                                          longitude:location.longitude
                                                               zoom:DEFAULT_ZOOM];
    GMSMapView *map = [GMSMapView mapWithFrame:self.frame camera:camera];
    map.myLocationEnabled = YES;
    map.frame = self.bounds;
    map.delegate = self;
    self.mapView = map;
    [self insertSubview:map atIndex:0];
    self.isEnabled = YES;
}

- (void) initWithBounds:(GMSCoordinateBounds *)bounds {
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:0
                                                          longitude:0
                                                               zoom:DEFAULT_ZOOM];
    GMSMapView *map = [GMSMapView mapWithFrame:self.frame camera:camera];
    [map animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:60.0f]];
    map.myLocationEnabled = YES;
    map.frame = self.bounds;
    map.delegate = self;
    self.mapView = map;
    [self addSubview:map];
    self.isEnabled = YES;
}

- (void) addMarker:(Location *)location {
    if (!self.isEnabled) {
        return;
    }
    
    GMSMarker *marker = [[GMSMarker alloc] init];

    marker.position = location.coord;
    marker.title = location.title;
    marker.snippet = location.snippet;
    marker.map = self.mapView;
    
    [self.markersArray addObject:marker];
}

- (void)addPolyline:(NSString *)polyline {
    if (!self.isEnabled) {
        return;
    }
    self.curPathIndex = 0;
    self.animatedPath = [[GMSMutablePath alloc] init];
    self.path = [GMSPath pathFromEncodedPath:polyline];
    self.animatedPolyline = [GMSPolyline polylineWithPath:self.animatedPath];
    self.animatedPolyline.map = self.mapView;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.005 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self animatePolylinePath];
    }];
}

- (void)animatePolylinePath {
    if (self.curPathIndex < self.path.count) {
        [self.animatedPath addCoordinate:[self.path coordinateAtIndex:self.curPathIndex]];
        self.animatedPolyline = [GMSPolyline polylineWithPath:self.animatedPath];
        self.animatedPolyline.strokeColor = [UIColor systemBlueColor];
        self.animatedPolyline.strokeWidth = 4;
        self.animatedPolyline.map = self.mapView;
        self.curPathIndex += 1;
    } else {
        [self.timer invalidate];
    }
}

- (void) clearMarkers {
    if (!self.isEnabled) {
        return;
    }
    
    for(GMSMarker *marker in self.markersArray) {
        marker.map = nil;
    }
    self.markersArray = [[NSMutableArray alloc] init];
}

- (void) setCameraToLoc:(CLLocationCoordinate2D)location animate:(BOOL)animate {
    if (!self.isEnabled) {
        return;
    }
    
    GMSCameraPosition *pos = [GMSCameraPosition cameraWithLatitude:location.latitude longitude:location.longitude zoom:self.mapView.camera.zoom];

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

# pragma mark - GMSMapViewDelegate

- (void) mapViewSnapshotReady:(GMSMapView *)mapView {
    [self.delegate didFinishLoading];
}

@end
