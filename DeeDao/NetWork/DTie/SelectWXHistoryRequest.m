//
//  SelectWXHistoryRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/18.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SelectWXHistoryRequest.h"

@implementation SelectWXHistoryRequest

- (instancetype)initWithStart:(NSInteger)start size:(NSInteger)size
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/browsingHistory/selectWXPostBrowsingHistory";
        
        [self setIntegerValue:start forParamKey:@"pageStart"];
        [self setIntegerValue:size forParamKey:@"pageSize"];
    }
    return self;
}

@end
