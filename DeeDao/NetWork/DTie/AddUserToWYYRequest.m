//
//  AddUserToWYYRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/17.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "AddUserToWYYRequest.h"

@implementation AddUserToWYYRequest

- (instancetype)initWithUserList:(NSArray *)userList postId:(NSInteger)postId
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/addUserToWYY";
        
        [self setValue:userList forParamKey:@"userIdList"];
        [self setIntegerValue:postId forParamKey:@"postId"];
    }
    return self;
}

@end
