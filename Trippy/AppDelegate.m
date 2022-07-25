//
//  AppDelegate.m
//  Trippy
//
//  Created by Catherine Lu on 7/5/22.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"
@import GoogleMaps;
@import GooglePlaces;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    // Set up Google SDKs
    [GMSServices provideAPIKey:dict[@"GMapsKey"]];
    [GMSPlacesClient provideAPIKey:dict[@"GMapsKey"]];
    
    // Set up Parse client
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
            configuration.applicationId = dict[@"appId"];
            configuration.clientKey = dict[@"clientKey"];
            configuration.server = @"https://parseapi.back4app.com";
        }];
    [Parse initializeWithConfiguration:config];
    
    return YES;
}


#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

@end
