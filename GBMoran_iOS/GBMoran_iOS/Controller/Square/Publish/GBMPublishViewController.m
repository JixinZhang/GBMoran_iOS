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

#define selfWidth  self.view.frame.size.width
#define selfHeight self.view.frame.size.height

@interface GBMPublishViewController ()<GBMPublishRequestDelegate>
{
    BOOL openOrNot;
}
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIControl *blackView;
@end

@implementation GBMPublishViewController

//发布按钮
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makePublishButton];
    self.navigationController.navigationBar.backgroundColor = [[UIColor alloc] initWithRed:230/255.0 green:106/255.0 blue:58/255.0 alpha:1];
    self.navigationController.navigationBar.barTintColor =[[UIColor alloc] initWithRed:230/255.0 green:106/255.0 blue:58/255.0 alpha:1];
    self.textView.delegate = self;
    [self.navigationController.navigationBar setAlpha:1.0];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-30, 10, 100, 30)];
    label.text = @"发布照片";
    label.textColor = [UIColor whiteColor];
    [self.navigationController.navigationBar  addSubview:label];
    
    self.photoView.image = self.publishPhoto;
}

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
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 重新定位响应
- (IBAction)publishLocation:(id)sender
{
    [self makeTableView];
}


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

#pragma mark - 发布照片事件
- (void)publishPhotoButtonClicked:(id)sender
{
    NSData *data = UIImageJPEGRepresentation(self.photoView.image, 1.0);
    GBMPublishRequest *request = [[GBMPublishRequest alloc] init];
    GBMUserModel *user = [GBMGlobal shareGlobal].user;
    [request sendLoginRequestWithUserId:user.userId token:user.token longitude:@"1" latitude:@"1" title:self.textView.text data:data delegate:self];
}

#pragma mark - 发布照片请求成功
- (void)requestSuccess:(GBMPublishRequest *)request picId:(NSString *)picId
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate loadMainViewWithController:self];
}

#pragma mark - 发布照片请求失败
- (void)requestFailed:(GBMPublishRequest *)request error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alert show];
}





@end
