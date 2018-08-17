//
//  SelectNotificationDeatilRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/17.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SelectNotificationDeatilRequest.h"

@implementation SelectNotificationDeatilRequest

- (instancetype)initWithNotificationID:(NSInteger)notificationID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = [NSString stringWithFormat:@"placeRemind/selectAllPostOneRemind/%ld", notificationID];
    }
    return self;
}

@end
