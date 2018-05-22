//
//  GetSeriesRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "GetSeriesRequest.h"

@implementation GetSeriesRequest

- (instancetype)init
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = @"series/selectMySeries";
    }
    return self;
}

@end
