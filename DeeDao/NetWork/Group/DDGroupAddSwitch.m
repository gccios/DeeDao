//
//  DDGroupAddSwitch.m
//  DeeDao
//
//  Created by 郭春城 on 2019/1/15.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DDGroupAddSwitch.h"

@implementation DDGroupAddSwitch

- (instancetype)initPostSwitchWithID:(NSInteger)postID state:(NSInteger)state
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/noAuthorDeliverSwitch";
        
        [self setIntegerValue:postID forParamKey:@"postId"];
        [self setIntegerValue:state forParamKey:@"isValid"];
    }
    return self;
}

@end
