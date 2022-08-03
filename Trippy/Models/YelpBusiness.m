//
//  YelpBusiness.m
//  Trippy
//
//  Created by Catherine Lu on 8/3/22.
//

#import "YelpBusiness.h"

@implementation YelpBusiness

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];

    if (self) {
        self.name = dict[@"name"];
        self.rating = dict[@"rating"];
        self.imageUrl = dict[@"image_url"];
        self.pricePoint = ((NSString *)dict[@"price"]).length;
        self.latitude = dict[@"coordinates"][@"latitude"];
        self.longitude = dict[@"coordinates"][@"longitude"];
        NSMutableArray *categories = [[NSMutableArray alloc] init];
        for (NSDictionary *cat in dict[@"categories"]) {
            [categories addObject:cat[@"title"]];
        }
        self.categories = categories;
    }
    
    return self;
}

@end
