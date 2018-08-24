//
//  GetMedalDetailRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "GetMedalDetailRequest.h"

@implementation GetMedalDetailRequest

- (instancetype)initWithID:(NSInteger)medalID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"medal/myMedalDetail";
        
        [self setIntegerValue:medalID forParamKey:@"medalId"];
        [self setIntegerValue:1 forParamKey:@"type"];
    }
    return self;
}

@end
