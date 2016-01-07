//
//  GBMPublishViewController.m
//  GBMoran_iOS
//
//  Created by ZhangBob on 10/27/15.
//  Copyright (c) 2015 JixinZhang. All rights reserved.
//

#import "GBMPublishViewController.h"
#import "GBMPublishCell.h"
#import "GBMPublishRequest.h"
#import "GBMUserModel.h"
#import "GBMGlobal.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>

#define selfWidth  self.view.frame.size.width
#define selfHeight self.view.frame.size.height

@interface GBMPublishViewController ()<CLLocationManagerDelegate>
{
    BOOL openOrNot;
    BOOL keyboardOpen;
    CGFloat keyboardOffSet;
    UIActivityIndicatorView *activity;
}
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIControl *blackView;
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,strong) NSMutableDictionary *locationDictionary;
@end

@implementation GBMPublishViewController

#pragma mark - makePublishButton
- (void)makePublishButton
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 65, 0, 50, 40)];
    button.backgroundColor = [UIColor whiteColor];
    button.alpha = 0.8;
    [button setTitle:@"发布" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(publishPhotoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 3.0;
    button.clipsToBounds = YES;
    [self.navigationController.navigationBar addSubview:button];
}




#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    //生成发布按钮
    [self makePublishButton];
    //生成返回按钮
    [self MakeBackButton];
    //获取地理位置
    [self getLatitudeAndLongitude];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeLocationValue:) name:@"observeLocationValue" object:nil];
    
    activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    CGFloat width = self.view.frame.size.width/2.0;
    [activity setCenter:CGPointMake(width, 160)];
    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:activity];

    self.photoView.image = self.publishPhoto;
    [self.view bringSubviewToFront:self.textView];
    keyboardOpen = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    self.navigationController.navigationBar.backgroundColor = [[UIColor alloc] initWithRed:230/255.0 green:106/255.0 blue:58/255.0 alpha:1];
    self.navigationController.navigationBar.barTintColor =[[UIColor alloc] initWithRed:230/255.0 green:106/255.0 blue:58/255.0 alpha:1];
    self.textView.delegate = self;
    [self.navigationController.navigationBar setAlpha:1.0];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-30, 10, 100, 30)];
    label.text = @"发布照片";
    label.textColor = [UIColor whiteColor];
    [self.navigationController.navigationBar  addSubview:label];
    
    self.numberLabel.backgroundColor = [UIColor lightGrayColor];
    [self.numberLabel bringSubviewToFront:self.textView];
    
}


#pragma mark - 限制字长&placeHolder
//限制字长，文字计数

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length >25) {
        [self.textView resignFirstResponder];
    }
    self.numberLabel.text = [NSString stringWithFormat:@"%lu/25",(unsigned long)textView.text.length];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"你想说的话"]) {
        textView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length <1) {
        textView.text = @"你想说的话";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 点击任意地方键盘收起
- (IBAction)touchDown:(id)sender
{
    [self.textView resignFirstResponder];
}





#pragma mark - 重新拍摄响应
- (IBAction)returnToCamera:(id)sender
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate addOrderView];
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}




#pragma mark - 重新定位响应
- (IBAction)publishLocation:(id)sender
{
    [self makeTableView];
}




#pragma mark - 定位服务
#pragma mark - 获取经纬度
- (void)getLatitudeAndLongitude
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    //位置移动至少1000m在通知委托处理更行
    self.locationManager.distanceFilter = 1000.0f;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0) {
        [_locationManager requestWhenInUseAuthorization];
    }
    
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"定位失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        [alert show];
    }
}


#pragma  mark - CLLocationManagerDelegate
//位置发生改变时触发
//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
//{
//    
//}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.locationDictionary = [NSMutableDictionary dictionary];
    NSLog(@"纬度:%f",newLocation.coordinate.latitude);
    NSLog(@"经度:%f",newLocation.coordinate.longitude);
    NSString *latitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
    [self.locationDictionary setValue:latitude forKey:@"latitude"];
    [self.locationDictionary setValue:longitude forKey:@"longitude"];
    CLLocationDegrees latitudeD = newLocation.coordinate.latitude;
    CLLocationDegrees longitudeD = newLocation.coordinate.longitude;
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:latitudeD longitude:longitudeD];
    CLGeocoder *revGeo = [[CLGeocoder alloc] init];
    [revGeo reverseGeocodeLocation:currentLocation
     
                 completionHandler:^(NSArray *placemarks,NSError *error){
                     if (!error && [placemarks count] > 0) {
                         NSDictionary *dict = [[placemarks objectAtIndex:0] addressDictionary];
                         NSLog(@"street address:%@",[dict objectForKey:@"Street"]);
                         self.locationLabel.text = [NSString stringWithFormat:@"%@%@%@",dict[@"City"],dict[@"SubLocality"],dict[@"Street"]];
                         [self.locationDictionary setValue:dict[@"Name"] forKey:@"location"];
                     }else{
                         NSLog(@"ERROR:%@",error);
                     }
                 }];
    [manager stopUpdatingLocation];
    
}


//定位失败
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"定位失败，原因：%@",error);
}




#pragma mark - 详细的定位列表
#pragma mark - makeTableView
- (void)makeTableView
{
    if (!self.tableView) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, selfHeight, selfWidth, 230)
                                                      style:UITableViewStylePlain];
        [self.tableView setDataSource:self];
        [self.tableView setDelegate:self];
        [self.tableView setBackgroundColor:[UIColor whiteColor]];
        [self.tableView setSeparatorColor:[UIColor blackColor]];
        [self.tableView setShowsHorizontalScrollIndicator:NO];
        [self.tableView setShowsVerticalScrollIndicator:YES];
        [self.tableView registerNib:[UINib nibWithNibName:@"GBMPublishCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"publishCell"];
        [self.view addSubview:self.tableView];
        openOrNot =NO;
    }
    
    if (openOrNot ==NO) {
        _blackView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, selfWidth, selfHeight-230)];
        [_blackView addTarget:self action:@selector(blackViewTouchDown) forControlEvents:UIControlEventTouchDown];
        _blackView.backgroundColor = [UIColor blackColor];
        _blackView.alpha = 0;
        [self.view addSubview:_blackView];
        [UIView animateWithDuration:1 animations:^{
            [self.tableView setFrame:CGRectMake(0, selfHeight-230, selfWidth, 230)];
            _blackView.alpha = 0.5;
        }];
        openOrNot = YES;
    }else{
        [UIView animateWithDuration:1 animations:^{
            [self.tableView setFrame:CGRectMake(0, selfHeight, selfWidth, 230)];
            _blackView.alpha = 0;
        }];
        [_blackView removeFromSuperview];
        openOrNot = NO;
    }
}


#pragma mark - tableView的Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GBMPublishCell *cell = [tableView dequeueReusableCellWithIdentifier:@"publishCell"];
    cell.nameLabel.text = @"上海";
    cell.placeLabel.text = @"上海浦东国际金融中心";
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 63;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (openOrNot ==YES) {
        [self makeTableView];
    }
}

-(void)blackViewTouchDown
{
    if (openOrNot == YES) {
        [self makeTableView];
    }
}




#pragma mark - 发布照片
#pragma mark - 点击发布按钮
- (void)publishPhotoButtonClicked:(id)sender
{
    NSData *data = UIImageJPEGRepresentation(self.photoView.image, 0.00001);
    GBMPublishRequest *request = [[GBMPublishRequest alloc] init];
    GBMUserModel *user = [GBMGlobal shareGlobal].user;
    [request sendLoginRequestWithUserId:user.userId
                                  token:user.token
                              longitude:[_locationDictionary valueForKey:@"longitude"]
                               latitude:[_locationDictionary valueForKey:@"latitude"]
                               location:self.locationLabel.text //[_locationDictionary valueForKey:@"location"]
                                  title:self.textView.text
                                   data:data
                               delegate:self];
    if ([activity isAnimating]) {
        [activity stopAnimating];
    }
    [activity startAnimating];
}


#pragma mark - 发布照片请求成功
- (void)requestSuccess:(GBMPublishRequest *)request picId:(NSString *)picId
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    
    if (self.tag == 1) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    }else if (self.tag == 2){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    [activity stopAnimating];
    
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate loadMainViewWithController:self];
}


#pragma mark - 发布照片请求失败
- (void)requestFailed:(GBMPublishRequest *)request error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误"
                                                    message:@"请重试"
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:@"取消", nil];
    [alert show];
    [activity stopAnimating];
}




#pragma mark - 返回按键
#pragma mark - BackButton
- (void)MakeBackButton
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancelAction:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}


#pragma mark - 返回动作
- (void)cancelAction:(id)sender
{
    if (self.tag == 1) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    }else if (self.tag == 2){
        [self.navigationController popViewControllerAnimated:YES];
    }
}




#pragma mark ---弹出键盘时适应
- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    if (keyboardOpen == NO) {
        NSDictionary *info = [notification userInfo];
        CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        CGRect endKeyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        //    CGFloat yOffset = endKeyboardRect.origin.y - beginKeyboardRect.origin.y;
        CGFloat keyboardHeight = endKeyboardRect.origin.y;
        CGRect textViewRect  = self.textView.frame;
        CGFloat textViewHeight = textViewRect.origin.y+textViewRect.size.height;
        keyboardOffSet = textViewHeight - keyboardHeight;
        [UIView animateWithDuration:duration animations:^{
            [self.view setFrame:CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y-keyboardOffSet, self.view.frame.size.width, self.view.frame.size.height)];
        }];
        
        keyboardOpen = YES;
    }
    
}

- (void)keyboardWillHide:(NSNotification *)notification{
    if (keyboardOpen == YES) {
        [UIView animateWithDuration:1 animations:^{
            [self.view setFrame:CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y+keyboardOffSet, self.view.frame.size.width, self.view.frame.size.height)];
        }];
        keyboardOpen = NO;
    }
}


@end
