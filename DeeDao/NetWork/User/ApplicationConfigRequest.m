//
//  ApplicationConfigRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/12.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "ApplicationConfigRequest.h"

@implementation ApplicationConfigRequest

- (instancetype)init
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = @"config/distanceAndRandom";
    }
    return self;
}

@end
