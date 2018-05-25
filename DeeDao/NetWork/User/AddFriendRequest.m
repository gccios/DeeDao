//
//  AddFriendRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "AddFriendRequest.h"

@implementation AddFriendRequest

- (instancetype)initWithUserId:(NSInteger)userId
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = [NSString stringWithFormat:@"user/applyFriend/%ld", userId];
    }
    return self;
}

@end
