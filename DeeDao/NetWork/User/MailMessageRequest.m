//
//  MailMessageRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/23.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "MailMessageRequest.h"

@implementation MailMessageRequest

- (instancetype)initWithNotificationStart:(NSInteger)start end:(NSInteger)end
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = [NSString stringWithFormat:@"mailbox/mailMsg/0/%ld/%ld", start, end];
    }
    return self;
}

- (instancetype)initWithExchangeStart:(NSInteger)start end:(NSInteger)end
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = [NSString stringWithFormat:@"mailbox/mailMsg/1/%ld/%ld", start, end];
    }
    return self;
}

@end
