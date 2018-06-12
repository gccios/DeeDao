//
//  SelectAttentionMeReuqest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/8.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SelectAttentionMeReuqest.h"

@implementation SelectAttentionMeReuqest

- (instancetype)init
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = @"user/selectConcernMeList";
    }
    return self;
}

@end
