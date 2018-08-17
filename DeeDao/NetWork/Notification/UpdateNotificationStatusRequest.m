//
//  UpdateNotificationStatusRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/17.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "UpdateNotificationStatusRequest.h"

@implementation UpdateNotificationStatusRequest

- (instancetype)initWithPostID:(NSInteger)postID status:(NSInteger)status
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"placeRemind/updateRemindStatus";
        
        [self setIntegerValue:postID forParamKey:@"postId"];
        [self setIntegerValue:status forParamKey:@"remindStatus"];
    }
    return self;
}

@end
