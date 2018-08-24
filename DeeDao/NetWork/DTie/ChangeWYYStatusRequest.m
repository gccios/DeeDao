//
//  ChangeWYYStatusRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "ChangeWYYStatusRequest.h"

@implementation ChangeWYYStatusRequest

- (instancetype)initWithPostID:(NSInteger)postID subType:(NSInteger)subType
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/collection/changeWYYStatus";
        
        [self setIntegerValue:postID forParamKey:@"postId"];
        [self setIntegerValue:3 forParamKey:@"type"];
        [self setIntegerValue:subType forParamKey:@"subType"];
    }
    return self;
}

@end
