//
//  GBMPublishViewController.h
//  GBMoran_iOS
//
//  Created by ZhangBob on 10/27/15.
//  Copyright (c) 2015 JixinZhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GBMPublishViewController : UIViewController<UITextViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (assign,nonatomic)NSInteger tag;
@property (strong,nonatomic)UIImage *publishPhoto;
@property (strong,nonatomic)UIImagePickerController *imagePicker;

- (IBAction)touchDown:(id)sender;
- (IBAction)returnToCamera:(id)sender;
- (IBAction)publishLocation:(id)sender;

@end
