//
//  UserLoginWXRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "UserLoginWXRequest.h"

@implementation UserLoginWXRequest

- (instancetype)initWithWeCode:(NSString *)code
{
    if (self = [super init]) {
        
        self.methodName = @"api/open/loginUser";
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setValue:@"wx_login" forParamKey:@"loginType"];
        [self setValue:code forParamKey:@"wxCode"];
        
    }
    return self;
}

- (instancetype)initWithTelNumber:(NSString *)telNumber code:(NSString *)code
{
    if (self = [super init]) {
        
        self.methodName = @"api/open/loginUser";
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setValue:telNumber forParamKey:@"phoneNum"];
        [self setValue:@"phone_login" forParamKey:@"loginType"];
        [self setValue:code forParamKey:@"phoneCode"];
        [self setValue:@"" forParamKey:@"pwd"];
        
    }
    return self;
}

@end
