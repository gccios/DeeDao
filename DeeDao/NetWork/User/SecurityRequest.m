//
//  SecurityRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/23.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SecurityRequest.h"

@implementation SecurityRequest

- (instancetype)init
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = @"scyGroup/selectMyScy";
    }
    return self;
}

@end
