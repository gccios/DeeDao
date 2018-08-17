//
//  ForwardSeriesRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/13.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "ForwardSeriesRequest.h"

@implementation ForwardSeriesRequest

- (instancetype)initWithSeriesID:(NSInteger)seriesID userList:(NSArray *)userList
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"series/forwardSeries";
        [self setIntegerValue:seriesID forParamKey:@"seriesId"];
        [self setValue:userList forParamKey:@"userIdList"];
    }
    return self;
}


@end
