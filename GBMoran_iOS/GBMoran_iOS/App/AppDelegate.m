//
//  AppDelegate.m
//  GBMoran_iOS
//
//  Created by ZhangBob on 10/17/15.
//  Copyright (c) 2015 JixinZhang. All rights reserved.
//

#import "AppDelegate.h"
#import "GBMMyViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (void)loadMainViewWithController:(UIViewController *)controller
{
    UIViewController *squareVC = [[UIViewController alloc] init];
    UINavigationController *squareNavigation = [[UINavigationController alloc] initWithRootViewController:squareVC];
    squareNavigation.navigationBar.barTintColor = [[UIColor alloc] initWithRed:230/250.0
                                                                         green:106/250.0
                                                                          blue:58/250.0 alpha:1];
    
    squareNavigation.tabBarItem.title = @"广场";
    squareNavigation.tabBarItem.image = [UIImage imageNamed:@"square"];
    
    UIStoryboard *myStoryboard = [UIStoryboard storyboardWithName:@"GBMMy" bundle:[NSBundle mainBundle]];
    GBMMyViewController *myVC = [myStoryboard instantiateViewControllerWithIdentifier:@"MyStoryboard"];
    myVC.tabBarItem.title = @"我的";
    myVC.tabBarItem.image = [UIImage imageNamed:@"my"];
    
    squareVC.tabBarController.viewControllers = @[squareNavigation,myVC];
    
    
}





- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
