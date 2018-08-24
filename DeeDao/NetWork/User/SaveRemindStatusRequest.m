//
//  SaveRemindStatusRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/23.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SaveRemindStatusRequest.h"
#import "UserManager.h"

@implementation SaveRemindStatusRequest

- (instancetype)initWithId:(NSInteger)remindID concern:(NSInteger)concern collection:(NSInteger)collection wyy:(NSInteger)wyy friend:(NSInteger)ifFriend remindInterval:(NSInteger)remindInterval
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"placeRemind/updateRemindSetUp";
        
        [self setIntegerValue:remindID forParamKey:@"id"];
        [self setIntegerValue:[UserManager shareManager].user.cid forParamKey:@"userId"];
        [self setIntegerValue:concern forParamKey:@"ifConcern"];
        [self setIntegerValue:collection forParamKey:@"ifCollection"];
        [self setIntegerValue:wyy forParamKey:@"ifWyy"];
        [self setIntegerValue:ifFriend forParamKey:@"ifFriend"];
        [self setIntegerValue:remindInterval forParamKey:@"remindInterval"];
        [self setIntegerValue:[[NSDate date] timeIntervalSince1970] forParamKey:@"updateTime"];
    }
    return self;
}

@end
