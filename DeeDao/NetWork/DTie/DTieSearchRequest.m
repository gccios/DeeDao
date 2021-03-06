//
//  DTieSearchRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/18.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieSearchRequest.h"

@implementation DTieSearchRequest

- (instancetype)initWithSortType:(NSInteger)sortType dataSources:(NSInteger)dataSources type:(NSInteger)type pageStart:(NSInteger)pageStart pageSize:(NSInteger)pageSize
{
    if (self = [super init]) {
        
        self.methodName = @"post/search/selectPostBySearch";
        self.httpMethod = BGNetworkRequestHTTPPost;
        
        [self setIntegerValue:sortType forParamKey:@"sortType"];
        [self setIntegerValue:dataSources forParamKey:@"dataSources"];
        [self setIntegerValue:type forParamKey:@"type"];
        [self setIntegerValue:pageStart forParamKey:@"pageStart"];
        [self setIntegerValue:pageSize forParamKey:@"pageSize"];
    }
    return self;
}

- (instancetype)initWithKeyWord:(NSString *)keyWord lat1:(double)lat1 lng1:(double)lng1 lat2:(double)lat2 lng2:(double)lng2 startDate:(double)startDate endDate:(double)endDate sortType:(NSInteger)sortType dataSources:(NSInteger)dataSources type:(NSInteger)type pageStart:(NSInteger)pageStart pageSize:(NSInteger)pageSize
{
    if (self = [super init]) {
        
        self.methodName = @"post/search/selectPostBySearch";
        self.httpMethod = BGNetworkRequestHTTPPost;
        
        if (!isEmptyString(keyWord)) {
            [self setValue:keyWord forParamKey:@"keyword"];
        }
        if (lat1 == 0 && lat2 == 0 && lng1 == 0 && lng2 == 0) {
            
        }else{
            [self setDoubleValue:lat1 forParamKey:@"lat1"];
            [self setDoubleValue:lng1 forParamKey:@"lng1"];
            [self setDoubleValue:lat2 forParamKey:@"lat2"];
            [self setDoubleValue:lng2 forParamKey:@"lng2"];
        }
//        [self setValue:startDate forParamKey:@"startDate"];
        [self setDoubleValue:startDate forParamKey:@"startDate"];
        [self setDoubleValue:endDate forParamKey:@"endDate"];
        
//        [self setValue:endDate forParamKey:@"endDate"];
        [self setIntegerValue:sortType forParamKey:@"sortType"];
        [self setIntegerValue:dataSources forParamKey:@"dataSources"];
        [self setIntegerValue:type forParamKey:@"type"];
        [self setIntegerValue:pageStart forParamKey:@"pageStart"];
        [self setIntegerValue:pageSize forParamKey:@"pageSize"];
        [self setIntegerValue:pageStart forParamKey:@"start"];
        [self setIntegerValue:pageSize forParamKey:@"length"];
        
        [self setValue:[NSArray new] forParamKey:@"idList"];
        [self setValue:[NSArray new] forParamKey:@"yearList"];
    }
    return self;
}

- (instancetype)initWithKeyWord:(NSString *)keyWord lat1:(double)lat1 lng1:(double)lng1 lat2:(double)lat2 lng2:(double)lng2 startDate:(double)startDate endDate:(double)endDate sortType:(NSInteger)sortType dataSources:(NSInteger)dataSources type:(NSInteger)type status:(NSInteger)status pageStart:(NSInteger)pageStart pageSize:(NSInteger)pageSize
{
    if (self = [super init]) {
        
        self.methodName = @"post/search/selectPostBySearch";
        self.httpMethod = BGNetworkRequestHTTPPost;
        
        if (!isEmptyString(keyWord)) {
            [self setValue:keyWord forParamKey:@"keyword"];
        }
        [self setDoubleValue:lat1 forParamKey:@"lat1"];
        [self setDoubleValue:lng1 forParamKey:@"lng1"];
        [self setDoubleValue:lat2 forParamKey:@"lat2"];
        [self setDoubleValue:lng2 forParamKey:@"lng2"];
        //        [self setValue:startDate forParamKey:@"startDate"];
        [self setDoubleValue:startDate forParamKey:@"startDate"];
        [self setDoubleValue:endDate forParamKey:@"endDate"];
        
        //        [self setValue:endDate forParamKey:@"endDate"];
        [self setIntegerValue:sortType forParamKey:@"sortType"];
        [self setIntegerValue:dataSources forParamKey:@"dataSources"];
        [self setIntegerValue:status forParamKey:@"status"];
        [self setIntegerValue:type forParamKey:@"type"];
        [self setIntegerValue:pageStart forParamKey:@"pageStart"];
        [self setIntegerValue:pageSize forParamKey:@"pageSize"];
        [self setIntegerValue:pageStart forParamKey:@"start"];
        [self setIntegerValue:pageSize forParamKey:@"length"];
        
        [self setValue:[NSArray new] forParamKey:@"idList"];
        [self setValue:[NSArray new] forParamKey:@"yearList"];
    }
    return self;
}

- (instancetype)initWithKeyWord:(NSString *)keyWord startDate:(double)startDate endDate:(double)endDate sortType:(NSInteger)sortType dataSources:(NSInteger)dataSources type:(NSInteger)type pageStart:(NSInteger)pageStart pageSize:(NSInteger)pageSize
{
    if (self = [super init]) {
        
        self.methodName = @"post/search/selectPostBySearch";
        self.httpMethod = BGNetworkRequestHTTPPost;
        
        if (!isEmptyString(keyWord)) {
            [self setValue:keyWord forParamKey:@"keyword"];
        }
        [self setDoubleValue:startDate forParamKey:@"startDate"];
        [self setDoubleValue:endDate forParamKey:@"endDate"];
        
        [self setIntegerValue:sortType forParamKey:@"sortType"];
        [self setIntegerValue:dataSources forParamKey:@"dataSources"];
        [self setIntegerValue:type forParamKey:@"type"];
        [self setIntegerValue:pageStart forParamKey:@"pageStart"];
        [self setIntegerValue:pageSize forParamKey:@"pageSize"];
        [self setIntegerValue:pageStart forParamKey:@"start"];
        [self setIntegerValue:pageSize forParamKey:@"length"];
        
        [self setValue:[NSArray new] forParamKey:@"idList"];
        [self setValue:[NSArray new] forParamKey:@"yearList"];
    }
    return self;
}

- (void)configTimeSort:(NSInteger)type
{
    if (type == 1) {
        [self setIntegerValue:1 forParamKey:@"sortFlag"];
    }
}

- (void)configWithAuthorID:(NSArray *)authorID
{
    if (authorID) {
        [self setValue:authorID forParamKey:@"authorId"];
    }
}

- (void)configGroupID:(NSInteger)groupID
{
    [self setIntegerValue:groupID forParamKey:@"groupId"];
}

@end
