//
//  GBMUserModel.h
//  GBMoran_iOS
//
//  Created by ZhangBob on 10/17/15.
//  Copyright (c) 2015 JixinZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GBMUserModel : NSObject

@property (nonatomic,copy) NSString *userName;
@property (nonatomic,copy) NSString *email;
@property (nonatomic,copy) NSString *password;
@property (nonatomic,copy) NSString *loginReturnMessage;
@property (nonatomic,copy) NSString *registerReturnMessage;

@end
