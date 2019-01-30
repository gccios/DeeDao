//
//  ClearNotificationRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2019/1/30.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "ClearNotificationRequest.h"

@implementation ClearNotificationRequest

- (instancetype)init
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"placeRemind/deleteAllRemind";
    }
    return self;
}

@end
