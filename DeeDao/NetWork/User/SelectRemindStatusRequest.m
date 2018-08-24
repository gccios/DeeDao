//
//  SelectRemindStatusRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/23.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SelectRemindStatusRequest.h"

@implementation SelectRemindStatusRequest

- (instancetype)init
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = @"placeRemind/showRemindSetUp";
    }
    return self;
}

@end
