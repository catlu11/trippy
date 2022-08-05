//
//  PriceUtils.m
//  Trippy
//
//  Created by Catherine Lu on 7/21/22.
//

#import "PriceUtils.h"
#import "Location.h"
#import "Itinerary.h"
#import "WaypointPreferences.h"

const static NSArray *multipliers = @[@0.7, @1, @1.5, @3];
const static NSDictionary *basePrices = @{@"food": @15,
                                          @"landmark": @10,
                                          @"airport": @15,
                                          @"amusement_park": @100,
                                          @"aquarium": @25,
                                          @"art_gallery": @20,
                                          @"bakery": @10,
                                          @"bar": @20,
                                          @"beauty_salon": @30,
                                          @"bicycle_store": @40,
                                          @"book_store": @15,
                                          @"bowling_alley": @10,
                                          @"bus_station": @3,
                                          @"cafe": @5,
                                          @"car_rental": @100,
                                          @"car_wash": @10,
                                          @"casino": @50,
                                          @"clothing_store": @20,
                                          @"convenience_store": @7,
                                          @"department_store": @20,
                                          @"drugstore": @10,
                                          @"electronics_store": @50,
                                          @"florist": @15,
                                          @"furniture_store": @200,
                                          @"gas_station": @30,
                                          @"hair_care": @25,
                                          @"hardware_store": @25,
                                          @"home_goods_store": @25,
                                          @"jewelry_store": @75,
                                          @"laundry": @5};

@implementation PriceUtils

+ (double)computeLocationCost:(Location *)loc {
    if (loc.estPrice) {
        return [loc.estPrice doubleValue];
    }
    double cumSum = 0;
    int count = 0;
    for (NSString *type in loc.types) {
        if (basePrices[type]) {
            cumSum += [basePrices[type] doubleValue];
        }
        count++;
    }
    int adjusted = [loc.priceLevel intValue] > 0 ? [loc.priceLevel intValue] - 1: 1;
    NSNumber *multiplier = multipliers[adjusted];
    return (cumSum / count) * [multiplier doubleValue];
}

+ (double)computeExpectedCost:(Location *)loc itinerary:(Itinerary *)itinerary {
    WaypointPreferences *pref = [itinerary getPreferenceByLocation:loc];
    if (pref.budget) {
        return [pref.budget doubleValue];
    }
    return [self computeLocationCost:loc];
}

+ (double)computeTotalCost:(Itinerary *)itinerary locations:(NSArray *)locations omitWaypoints:(NSArray *)omitWaypoints {
    double sum = 0;
    for (int i = 0; i < locations.count; i++) {
        if ([omitWaypoints containsObject:@(i)]) {
            continue;
        }
        sum += [self computeExpectedCost:locations[i] itinerary:itinerary];
    }
    return sum;
}

@end
