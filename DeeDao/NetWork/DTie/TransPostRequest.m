//
//  TransPostRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/5.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "TransPostRequest.h"

@implementation TransPostRequest

- (instancetype)initWithPostID:(NSInteger)postID userList:(NSArray *)userList
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/transmitPost";
        [self setIntegerValue:postID forParamKey:@"postId"];
        [self setValue:userList forParamKey:@"idList"];
    }
    return self;
}

@end
