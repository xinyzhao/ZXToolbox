//
//  AppDelegate.m
//  ZXToolboxDemo
//
//  Created by xyz on 2020/1/9.
//  Copyright © 2020 xinyzhao. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"NaviViewController"];
    _window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    _window.rootViewController = vc;
    [_window makeKeyAndVisible];
    return YES;
}

@end
