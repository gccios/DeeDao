//
//  UserInfoRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "UserInfoRequest.h"

@implementation UserInfoRequest

- (instancetype)initWithUserId:(NSInteger)userId
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"user/selectUserById";
        
        [self setIntegerValue:userId forParamKey:@"id"];
        [self setIntegerValue:0 forParamKey:@"start"];
        [self setIntegerValue:10 forParamKey:@"length"];
    }
    return self;
}

@end
