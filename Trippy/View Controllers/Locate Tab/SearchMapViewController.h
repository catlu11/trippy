//
//  ViewController.h
//  Trippy
//
//  Created by Catherine Lu on 7/5/22.
//

#import <UIKit/UIKit.h>
@import GoogleMaps;

@interface SearchMapViewController : UIViewController
@property (strong, nonatomic) NSString *initialSearch;
@property (assign, nonatomic) CLLocationCoordinate2D initialCoord;
@end

