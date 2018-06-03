//
//  SelectAttentionRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/3.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SelectAttentionRequest.h"

@implementation SelectAttentionRequest

- (instancetype)init
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = @"user/selectMyConcernList";
    }
    return self;
}

@end
