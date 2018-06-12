//
//  DTiePOIRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/7.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTiePOIRequest.h"

@implementation DTiePOIRequest

- (instancetype)initWithLat:(double)lat lng:(double)lng
{
    if (self = [super init]) {
        
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/search/selectPostByPosition";
        [self setDoubleValue:lat forParamKey:@"lat"];
        [self setDoubleValue:lng forParamKey:@"lng"];
        
    }
    return self;
}

@end
