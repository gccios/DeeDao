//
//  SuperManagerRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2019/1/16.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "SuperManagerRequest.h"

@implementation SuperManagerRequest

- (instancetype)initWithPageStart:(NSInteger)pageStart pageSize:(NSInteger)pageSize
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"super/selectAllUser";
        
        [self setIntegerValue:pageStart forParamKey:@"pageStart"];
        [self setIntegerValue:pageSize forParamKey:@"pageSize"];
    }
    return self;
}

- (instancetype)initFreezeUser:(NSInteger)userID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"super/freezeUser";
        
        [self setIntegerValue:userID forParamKey:@"userId"];
    }
    return self;
}

@end
