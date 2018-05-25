//
//  MailMessageRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/23.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "MailMessageRequest.h"

@implementation MailMessageRequest

- (instancetype)init
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = @"mailbox/mailMsg/0/1000";
    }
    return self;
}

@end
