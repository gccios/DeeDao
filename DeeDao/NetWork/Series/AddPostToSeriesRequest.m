//
//  AddPostToSeriesRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/17.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "AddPostToSeriesRequest.h"

@implementation AddPostToSeriesRequest

- (instancetype)initWithPostList:(NSArray *)postList seriesID:(NSInteger)seriesID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"series/addPostToSeries";
        
        [self setValue:postList forParamKey:@"postIdList"];
        [self setIntegerValue:seriesID forParamKey:@"seriesId"];
    }
    return self;
}

@end
