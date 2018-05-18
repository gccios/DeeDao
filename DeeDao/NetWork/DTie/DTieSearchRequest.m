//
//  DTieSearchRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/18.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieSearchRequest.h"

@implementation DTieSearchRequest

- (instancetype)initWithKeyWord:(NSString *)keyWord lat1:(double)lat1 lng1:(double)lng1 lat2:(double)lat2 lng2:(double)lng2 startDate:(NSString *)startDate endDate:(NSString *)endDate sortType:(NSInteger)sortType dataSources:(NSInteger)dataSources type:(NSInteger)type pageStart:(NSInteger)pageStart pageSize:(NSInteger)pageSize
{
    if (self = [super init]) {
        
        self.methodName = @"post/search/selectPostBySearch";
        self.httpMethod = BGNetworkRequestHTTPPost;
        
        [self setValue:keyWord forParamKey:@"keyWord"];
        [self setDoubleValue:lat1 forParamKey:@"lat1"];
        [self setDoubleValue:lng1 forParamKey:@"lng1"];
        [self setDoubleValue:lat2 forParamKey:@"lat2"];
        [self setDoubleValue:lng2 forParamKey:@"lng2"];
        [self setValue:startDate forParamKey:@"startDate"];
        [self setValue:endDate forParamKey:@"endDate"];
        [self setIntegerValue:sortType forParamKey:@"sortType"];
        [self setIntegerValue:dataSources forParamKey:@"dataSources"];
        [self setIntegerValue:type forParamKey:@"type"];
        [self setIntegerValue:pageStart forParamKey:@"pageStart"];
        [self setIntegerValue:pageSize forParamKey:@"pageSize"];
    }
    return self;
}

@end
