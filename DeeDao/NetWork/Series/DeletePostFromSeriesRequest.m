//
//  DeletePostFromSeriesRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/23.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DeletePostFromSeriesRequest.h"

@implementation DeletePostFromSeriesRequest

- (instancetype)initWithPostID:(NSInteger)postID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"series/deletePostFromSeries";
        
        [self setIntegerValue:postID forParamKey:@"postId"];
    }
    return self;
}

@end
