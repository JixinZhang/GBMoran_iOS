//
//  AppDelegate.h
//  GBMoran_iOS
//
//  Created by ZhangBob on 10/17/15.
//  Copyright (c) 2015 JixinZhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)loadMainViewWithController:(UIViewController *)controller;

@end

