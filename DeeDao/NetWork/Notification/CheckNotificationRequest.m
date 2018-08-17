//
//  CheckNotificationRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/17.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "CheckNotificationRequest.h"
#import "DDLocationManager.h"

@implementation CheckNotificationRequest

- (instancetype)init
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"placeRemind/selectPostRemind";
        
        [self setDoubleValue:[DDLocationManager shareManager].userLocation.location.coordinate.latitude forParamKey:@"lat"];
        [self setDoubleValue:[DDLocationManager shareManager].userLocation.location.coordinate.longitude forParamKey:@"lng"];
    }
    return self;
}

@end
