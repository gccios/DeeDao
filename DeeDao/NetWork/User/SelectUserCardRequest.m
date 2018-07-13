//
//  SelectUserCardRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/12.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SelectUserCardRequest.h"

@implementation SelectUserCardRequest

- (instancetype)initWithStart:(NSInteger)start end:(NSInteger)end
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"userCard/selectMyCards";
        [self setIntegerValue:start forParamKey:@"pageStart"];
        [self setIntegerValue:end forParamKey:@"pageSize"];
    }
    return self;
}

@end
