//
//  AppDelegate.m
//  GBMoran_iOS
//
//  Created by ZhangBob on 10/17/15.
//  Copyright (c) 2015 JixinZhang. All rights reserved.
//

#import "AppDelegate.h"
#import "GBMMyViewController.h"
#import "GBMLoginViewController.h"
#import "GBMSquareViewController.h"
#import "GBMPublishViewController.h"

#define viewWidth self.window.frame.size.width
#define viewHeight self.window.frame.size.height

@interface AppDelegate ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong)UITabBarController *tabBarController;
@property (nonatomic,strong)UIImagePickerController *pickerController;


@end

@implementation AppDelegate

- (void)loadLoginView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"GBMLoginAndRegister" bundle:[NSBundle mainBundle]];
    self.loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginStoryboard"];
    self.window.rootViewController = self.loginViewController;
}

- (void)loadMainViewWithController:(UIViewController *)controller
{
    UIStoryboard *squareStoryboard = [UIStoryboard storyboardWithName:@"GBMSquare" bundle:[NSBundle mainBundle]];
    GBMSquareViewController *squareVC = [squareStoryboard instantiateViewControllerWithIdentifier:@"SquareStoryboard"];
    UINavigationController *nav1 = [[UINavigationController alloc]initWithRootViewController:squareVC];
    nav1.navigationBar.barTintColor = [[UIColor alloc]initWithRed:230/255.0 green:106/255.0 blue:58/255.0 alpha:1];
    
    nav1.tabBarItem.title = @"广场";
    nav1.tabBarItem.image = [UIImage imageNamed:@"square"];
    
    UIStoryboard *myStoryboard
    = [UIStoryboard storyboardWithName:@"GBMMy" bundle:[NSBundle mainBundle]];
    GBMMyViewController *myVC = [myStoryboard instantiateViewControllerWithIdentifier:@"MyStoryboard"];
    myVC.tabBarItem.title = @"我的";
    myVC.tabBarItem.image = [UIImage imageNamed:@"my"];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[ nav1,myVC];
    
    // 添加切换页面的动画效果
    [controller presentViewController:self.tabBarController animated:YES completion:nil];
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.loginViewController.view.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         self.loginViewController = nil;
                     }];
    
    UIButton *photoButton = [[UIButton alloc]initWithFrame:CGRectMake(viewWidth/2-60, -25, 120, 50)];
    [photoButton setImage:[UIImage imageNamed:@"publish"] forState:UIControlStateNormal];
    [photoButton addTarget:self action:@selector(addOrderView) forControlEvents:UIControlEventTouchUpInside];
    [self.tabBarController.tabBar addSubview:photoButton];
    
}
#pragma mark - 拍照按钮
- (void)addOrderView
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"拍照",@"从手机相册选择", nil];
    [sheet showInView:self.tabBarController.view];
}

#pragma mark - UIActionSheet delegat method

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.pickerController = [[UIImagePickerController alloc] init];
    
    if (buttonIndex == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.pickerController.allowsEditing = NO;
            
            self.pickerController.delegate = self;
            [self.tabBarController presentViewController:self.pickerController animated:YES completion:nil];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"无法获取相机" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }else if(buttonIndex == 1){
        self.pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.pickerController.delegate = self;
        [self.tabBarController presentViewController:self.pickerController animated:YES completion:nil];
    }
}


#pragma mark - UIImagePickerController delegate method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    CGSize imageSize = image.size;
    imageSize.height = 626;
    imageSize.width = 213;
    image = [self imageWithImage:image scaledToSize:imageSize];
    
    
    if (self.pickerController.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"GBMPublish" bundle:nil];
        GBMPublishViewController *publish = [storyboard instantiateViewControllerWithIdentifier:@"CMJ"];
        publish.tag = 2;
        publish.publishPhoto = image;
        [picker pushViewController:publish animated:YES];
    }else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"GBMPublish" bundle:nil];
        GBMPublishViewController *publish = [storyboard instantiateViewControllerWithIdentifier:@"CMJ"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:publish];
        publish.tag = 1;
        publish.imagePicker = picker;
        publish.publishPhoto = image;
        [picker presentViewController:navigationController animated:YES completion:nil];
    }
    
}

#pragma mark - 图片压缩
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}







- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
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
