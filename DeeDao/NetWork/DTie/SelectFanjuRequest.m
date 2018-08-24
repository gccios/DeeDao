//
//  SelectFanjuRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/23.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SelectFanjuRequest.h"

@implementation SelectFanjuRequest

- (instancetype)initWithStart:(NSInteger)start size:(NSInteger)pageSize
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/collection/selectMyWYYList";
        
        [self setIntegerValue:start forParamKey:@"pageStart"];
        [self setIntegerValue:pageSize forParamKey:@"pageSize"];
    }
    return self;
}

@end
