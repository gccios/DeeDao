//
//  DTieCancleWYYRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieCancleWYYRequest.h"

@implementation DTieCancleWYYRequest

- (instancetype)initWithPostID:(NSInteger)posdId
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/collection/cancelPostWYY";
        [self setIntegerValue:posdId forParamKey:@"postId"];
    }
    return self;
}

@end
