//
//  SelectMapYaoyueRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/26.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SelectMapYaoyueRequest.h"

@implementation SelectMapYaoyueRequest

- (instancetype)initWithFriendList:(NSArray *)friendList
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/collection/selectWYYFriendsMap";
        
        [self setValue:friendList forParamKey:@"friendsList"];
    }
    return self;
}

@end
