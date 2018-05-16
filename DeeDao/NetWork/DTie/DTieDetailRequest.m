//
//  DTieDetailRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/16.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieDetailRequest.h"

@implementation DTieDetailRequest

- (instancetype)initWithID:(NSInteger)cid type:(NSInteger)type start:(NSInteger)start length:(NSInteger)length
{
    if (self = [super init]) {
        
        self.methodName = @"post/showPostDetail";
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setIntegerValue:cid forParamKey:@"postId"];
        [self setIntegerValue:type forParamKey:@"type"];
        [self setIntegerValue:start forParamKey:@"start"];
        [self setIntegerValue:length forParamKey:@"length"];
        
    }
    return self;
}

@end
