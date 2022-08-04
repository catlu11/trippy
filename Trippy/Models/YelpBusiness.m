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
        self.city = dict[@"location"][@"city"];
        self.state = dict[@"location"][@"state"];
        self.rating = dict[@"rating"];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:dict[@"image_url"]]];
        self.image = [UIImage imageWithData:data];
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
