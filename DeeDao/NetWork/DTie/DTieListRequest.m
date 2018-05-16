//
//  DTieListRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/16.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieListRequest.h"

@implementation DTieListRequest

- (instancetype)initWithStart:(NSInteger)start length:(NSInteger)length
{
    if (self = [super init]) {
        
        self.methodName = @"post/selectMyDPost";
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setIntegerValue:start forParamKey:@"start"];
        [self setIntegerValue:length forParamKey:@"length"];
        
    }
    return self;
}


@end
