//
//  DTieSearchRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/18.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface DTieSearchRequest : BGNetworkRequest

- (instancetype)initWithSortType:(NSInteger)sortType dataSources:(NSInteger)dataSources type:(NSInteger)type pageStart:(NSInteger)pageStart pageSize:(NSInteger)pageSize;

- (instancetype)initWithKeyWord:(NSString *)keyWord lat1:(double)lat1 lng1:(double)lng1 lat2:(double)lat2 lng2:(double)lng2 startDate:(double)startDate endDate:(double)endDate sortType:(NSInteger)sortType dataSources:(NSInteger)dataSources type:(NSInteger)type pageStart:(NSInteger)pageStart pageSize:(NSInteger)pageSize;

- (instancetype)initWithKeyWord:(NSString *)keyWord lat1:(double)lat1 lng1:(double)lng1 lat2:(double)lat2 lng2:(double)lng2 startDate:(double)startDate endDate:(double)endDate sortType:(NSInteger)sortType dataSources:(NSInteger)dataSources type:(NSInteger)type status:(NSInteger)status pageStart:(NSInteger)pageStart pageSize:(NSInteger)pageSize;

- (instancetype)initWithKeyWord:(NSString *)keyWord startDate:(double)startDate endDate:(double)endDate sortType:(NSInteger)sortType dataSources:(NSInteger)dataSources type:(NSInteger)type pageStart:(NSInteger)pageStart pageSize:(NSInteger)pageSize;

- (void)configTimeSort:(NSInteger)type;

- (void)configWithAuthorID:(NSArray *)authorID;

- (void)configGroupID:(NSInteger)groupID;

@end
