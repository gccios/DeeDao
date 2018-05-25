//
//  SelectFriendRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SelectFriendRequest.h"

@implementation SelectFriendRequest

- (instancetype)init
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = @"user/selectMyFriendList";
    }
    return self;
}

@end
