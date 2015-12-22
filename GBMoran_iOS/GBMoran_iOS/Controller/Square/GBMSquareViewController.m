//
//  GBMSquareViewController.m
//  GBMoran_iOS
//
//  Created by ZhangBob on 10/25/15.
//  Copyright (c) 2015 JixinZhang. All rights reserved.
//

#import "GBMSquareViewController.h"
#import "GBMSquareCell.h"
#import "KxMenu.h"
#define SPAN  MACoordinateSpanMake(0.025, 0.025)
#import "MJRefresh.h"
#import "GBMSquareRequest.h"
#import "GBMUserModel.h"
#import "GBMGlobal.h"

#import "GBMPictureModel.h"
#import "GBMSquareModel.h"
#import "GBMViewDetailViewController.h"
#import "UIImageView+WebCache.h"
#define MJRandomData [NSString stringWithFormat:@"随机数据---%d", arc4random_uniform(1000000)]
@interface GBMSquareViewController ()<UITableViewDelegate, UITableViewDataSource, GBMSquareRequestDelegate,CLLocationManagerDelegate>
@property (nonatomic, strong) NSArray *scrollArray;
@property (nonatomic ,strong) NSMutableDictionary * userLocationDict;

@property (strong, nonatomic) NSMutableArray *data; // Temp Refresh

@property (nonatomic, strong) NSDictionary *dataDic;
@property (nonatomic, strong) NSArray *dataArr;

@property (nonatomic, strong) UIButton *titleButton;



@property (nonatomic, strong) NSMutableArray *addrArray;
@property (nonatomic, strong) NSMutableArray *pictureArray;

@property(nonatomic , strong) CLLocationManager *locationManager;


@end

@implementation GBMSquareViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //存放返回数据
    self.locationDic = [NSMutableDictionary dictionary];
    
    //locationManager初始化和一些准备设置
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //距离过滤器，位置的改变不会每一次都去通知委托，而是在移动了足够的距离时才会通知委托程序，单位是米
    self.locationManager.distanceFilter = 1000.0f;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0) {
        [_locationManager requestWhenInUseAuthorization];
    }
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
        NSLog(@"latitude is %f",self.locationManager.location.coordinate.latitude);
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"定位失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        [alert show];
    }
    
    
    //NavigationBar的设置
    self.titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.titleButton setTitle:@"全部" forState:UIControlStateNormal];
    self.titleButton.frame = CGRectMake(0, 0, 200, 35);
    [self.titleButton addTarget:self action:@selector(titleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.titleButton setImage:[UIImage imageNamed:@"icon_arrow_down"] forState:UIControlStateNormal];
    self.titleButton.imageEdgeInsets = UIEdgeInsetsMake(0, 133, 0, 0);
    self.titleButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 40);
    
    self.navigationItem.titleView = self.titleButton;
    
    [self requestAllData];
    //头刷新
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView.header endRefreshing];
            [self.tableView reloadData];
            
        });
    }];
    
    self.tableView.header.automaticallyChangeAlpha = YES;
    //尾刷新
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView.footer endRefreshing];
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}




// 载入网络刷新数据
-(void) loadUpPullData {
    for (int i; i < 5; i ++) {
        [self.data insertObject:MJRandomData atIndex:0];
    }
    
}


-(void) upPullRefresh {
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadUpPullData];
    }];
    
    [self.tableView.header beginRefreshing];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"numberOfSectionsInTabelView: %zd", self.addrArray.count);
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"addrArray: %zd", self.addrArray.count);
    return self.addrArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    static NSString *str = @"squareCell";
    GBMSquareCell * cell = [tableView dequeueReusableCellWithIdentifier:@"squareCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[GBMSquareCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"squareCell"];
    }
    
    GBMSquareModel *squareModel = self.addrArray[indexPath.row][0];
    cell.squareVC = self;
//    NSLog(@"%zd", indexPath.section);
    cell.locationLabel.text = squareModel.addr;
    cell.dataArr = self.dataDic[self.addrArray[indexPath.row]];
    [cell.collectionView reloadData];
    return cell;
}



- (void)squareRequestSuccess:(GBMSquareRequest *)request dictionary:(NSDictionary *)dictionary
{
    //    NSLog(@"%@", dictionary);
    self.addrArray = [NSMutableArray arrayWithArray:[dictionary allKeys]];
    self.pictureArray = [NSMutableArray arrayWithArray:dictionary[@"pic"]];
    self.dataDic = dictionary;
    [self.tableView reloadData];
    
}
- (void)squareRequestFailed:(GBMSquareRequest *)request error:(NSError *)error
{
    
}

#pragma mark - toCheckPicture
- (void)toCheckPicture
{
    GBMViewDetailViewController *detailVC = [[UIStoryboard storyboardWithName:@"GBMViewDetail" bundle:nil] instantiateViewControllerWithIdentifier:@"detailVC"];
    [detailVC.photoImage sd_setImageWithURL:[NSURL URLWithString:_pic_url]];
    detailVC.pic_id=_pic_id;
    detailVC.pic_url =_pic_url;
    [self.navigationController pushViewController:detailVC animated:YES];
}





#pragma mark - CLLocationManagerDelegate Methods
//位置更新时触发



- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //获取经纬度
    self.locationDic = [NSMutableDictionary dictionary];
    NSLog(@"纬度:%f",newLocation.coordinate.latitude);
    NSLog(@"经度:%f",newLocation.coordinate.longitude);
    NSString *latitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
    [self.locationDic setValue:latitude forKey:@"latitude"];
    [self.locationDic setValue:longitude forKey:@"longitude"];
    CLLocationDegrees latitude2  = newLocation.coordinate.latitude;
    CLLocationDegrees longitude2 = newLocation.coordinate.longitude;
    
    
    CLLocation *c = [[CLLocation alloc] initWithLatitude:latitude2 longitude:longitude2];
    //创建位置
    CLGeocoder *revGeo = [[CLGeocoder alloc] init];
    [revGeo reverseGeocodeLocation:c
     //方向地理编码
                 completionHandler:^(NSArray *placemarks,NSError *error){
                     if (!error && [placemarks count] > 0) {
                         NSDictionary *dict = [[placemarks objectAtIndex:0] addressDictionary];
                         NSLog(@"street address:%@",[dict objectForKey:@"Street"]);
                         [self.locationDic setValue:dict[@"Name"] forKey:@"location"];
                     }else{
                         NSLog(@"ERROR:%@",error);
                     }
                 }];
    
    //停止更新
    [manager stopUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error:%@",error);
}

#pragma mark - 搜索附近功

//附近搜索功能
- (void)titleButtonClicked:(UIButton *)button
{
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:@" 显示全部"
                     image:nil
                    target:self
                    action:@selector(requestAllData)],
      
      [KxMenuItem menuItem:@"附近500米"
                     image:nil
                    target:self
                    action:@selector(request500kilometerData)],
      [KxMenuItem menuItem:@"附近1000米"
                     image:nil
                    target:self
                    action:@selector(request1000kilometerData)],
      [KxMenuItem menuItem:@"附近1500米"
                     image:nil
                    target:self
                    action:@selector(request1000kilometerData)],
      
      ];
    
    
    UIButton *btn = (UIButton *)button;
    CGRect editImageFrame = btn.frame;
    
    UIView *targetSuperview = btn.superview;
    CGRect rect = [targetSuperview convertRect:editImageFrame toView:[[UIApplication sharedApplication] keyWindow]];
    
    [KxMenu showMenuInView:[[UIApplication sharedApplication] keyWindow]
                  fromRect:rect
                 menuItems:menuItems];
}

- (void)requestAllData
{
    NSDictionary *paramDic = @{@"user_id":[GBMGlobal shareGlobal].user.userId, @"token":[GBMGlobal shareGlobal].user.token, @"longitude":@"121.47794", @"latitude":@"31.22516", @"distance":@"1000"};
    
    GBMSquareRequest *squareRequest = [[GBMSquareRequest alloc] init];
    [squareRequest sendSquareRequestWithParameter:paramDic delegate:self];
}


- (void)request1000kilometerData
{
    NSDictionary *paramDic = @{@"user_id":[GBMGlobal shareGlobal].user.userId, @"token":[GBMGlobal shareGlobal].user.token, @"longitude":[self.locationDic valueForKey:@"longitude"], @"latitude":[self.locationDic valueForKey:@"latitude"], @"distance":@"1000"};
    
    GBMSquareRequest *squareRequest = [[GBMSquareRequest alloc] init];
    [squareRequest sendSquareRequestWithParameter:paramDic delegate:self];}







@end