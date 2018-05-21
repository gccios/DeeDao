
//
//  UserLogoutRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "UserLogoutRequest.h"

@implementation UserLogoutRequest

- (instancetype)init
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = @"api/open/logOut";
    }
    return self;
}

@end
