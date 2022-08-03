//
//  YelpBusiness.h
//  Trippy
//
//  Created by Catherine Lu on 8/3/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YelpBusiness : NSObject
- (instancetype)initWithDictionary:(NSDictionary *)dict;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSNumber *rating;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSArray *categories;
@property int *pricePoint;
@end

NS_ASSUME_NONNULL_END
