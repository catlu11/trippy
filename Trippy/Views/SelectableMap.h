//
//  SelectableMap.h
//  Trippy
//
//  Created by Catherine Lu on 7/6/22.
//

#import <UIKit/UIKit.h>
@class Location;
@import GoogleMaps;

NS_ASSUME_NONNULL_BEGIN

@interface SelectableMap : UIView
- (void) initWithCenter:(CLLocationCoordinate2D)location;
- (void) initWithBounds:(GMSCoordinateBounds *)bounds;
- (void) addMarker:(Location *)location;
- (void) addPolyline:(NSString *)polyline;
- (void) clearMarkers;
- (void) setCameraToLoc:(CLLocationCoordinate2D)location animate:(BOOL)animate;
- (CLLocationCoordinate2D) getCenter;
@end

NS_ASSUME_NONNULL_END
