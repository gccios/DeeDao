//
//  GetWXAccessTokenRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "GetWXAccessTokenRequest.h"

@implementation GetWXAccessTokenRequest

- (instancetype)init
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = @"config/getWxAccessToken";
    }
    return self;
}

@end
