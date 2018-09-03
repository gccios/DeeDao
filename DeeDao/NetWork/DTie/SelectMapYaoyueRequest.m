//
//  SelectMapYaoyueRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/26.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SelectMapYaoyueRequest.h"

@implementation SelectMapYaoyueRequest

- (instancetype)initWithFriendList:(NSArray *)friendList lat1:(double)lat1 lng1:(double)lng1 lat2:(double)lat2 lng2:(double)lng2
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/collection/selectWYYFriendsMap";
        
        [self setDoubleValue:lat1 forParamKey:@"lat1"];
        [self setDoubleValue:lng1 forParamKey:@"lng1"];
        [self setDoubleValue:lat2 forParamKey:@"lat2"];
        [self setDoubleValue:lng2 forParamKey:@"lng2"];
        
        [self setValue:friendList forParamKey:@"friendsList"];
    }
    return self;
}

@end
