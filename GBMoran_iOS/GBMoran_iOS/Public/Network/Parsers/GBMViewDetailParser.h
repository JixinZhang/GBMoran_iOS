//
//  GBMViewDetailParser.h
//  GBMoran_iOS
//
//  Created by ZhangBob on 10/25/15.
//  Copyright (c) 2015 JixinZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GBMViewDetailParser : NSObject

- (NSArray*)parseJson:(NSData *)data;
@property (nonatomic, strong) NSMutableArray *addrArray;
@property (nonatomic, strong) NSMutableArray *pictureArray;

@end
