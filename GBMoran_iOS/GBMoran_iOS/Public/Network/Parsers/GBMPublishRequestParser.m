//
//  GBMPublishRequestParser.m
//  GBMoran_iOS
//
//  Created by ZhangBob on 11/2/15.
//  Copyright (c) 2015 JixinZhang. All rights reserved.
//

#import "GBMPublishRequestParser.h"

@implementation GBMPublishRequestParser

- (GBMPublishModel *)parseJson:(NSData *)data
{
    NSError *error = nil;
    id jsonDic = [NSJSONSerialization JSONObjectWithData:data
                                                 options:NSJSONReadingAllowFragments
                                                   error:&error];
    if (error) {
        NSLog(@"the publish parser is not not work");
    }else{
        if ([[jsonDic class] isSubclassOfClass:[NSDictionary class]]) {
            id returnMessage = [jsonDic valueForKey:@"data"];
            id returnPic = [returnMessage valueForKey:@"pic_id"];
            if ([[returnPic class] isSubclassOfClass:[NSString class]]) {
                GBMPublishModel *user = [[GBMPublishModel alloc] init];
                user.picId = returnPic;
                return user;
            }
        }
    }
    return nil;
}


@end
