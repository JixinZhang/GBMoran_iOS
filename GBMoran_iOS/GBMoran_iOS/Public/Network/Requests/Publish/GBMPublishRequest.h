//
//  GBMPublishRequest.h
//  GBMoran_iOS
//
//  Created by ZhangBob on 11/2/15.
//  Copyright (c) 2015 JixinZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBMPublishRequest;

@protocol GBMPublishRequestDelegate <NSObject>

- (void)requestSuccess:(GBMPublishRequest *)request picId:(NSString *)picId;
- (void)requestFailed:(GBMPublishRequest *)request error:(NSError *)error;

@end

@interface GBMPublishRequest : NSObject

@property (nonatomic, strong)NSURLConnection *urlConnection;
@property (nonatomic, strong)NSMutableData   *receivedData;
@property (nonatomic, assign)id<GBMPublishRequestDelegate> delegate;

- (void)sendLoginRequestWithUserId:(NSString *)userId
                             token:(NSString *)token
                         longitude:(NSString *)longitude
                          latitude:(NSString *)latitude
                          location:(NSString *)locaiton
                             title:(NSString *)title
                              data:(NSData *)data
                          delegate:(id<GBMPublishRequestDelegate>)delegate;

@end
