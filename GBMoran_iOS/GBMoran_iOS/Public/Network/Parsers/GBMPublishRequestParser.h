//
//  GBMPublishRequestParser.h
//  GBMoran_iOS
//
//  Created by ZhangBob on 11/2/15.
//  Copyright (c) 2015 JixinZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBMPublishModel.h"

@interface GBMPublishRequestParser : NSObject

- (GBMPublishModel *)parseJson:(NSData *)data;

@end
