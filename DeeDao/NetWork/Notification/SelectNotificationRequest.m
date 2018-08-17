//
//  SelectNotificationRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/17.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SelectNotificationRequest.h"

@implementation SelectNotificationRequest

- (instancetype)init
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = @"placeRemind/selectAllRemind";
    }
    return self;
}

@end
