//
//  SaveFriendOrConcernRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SaveFriendOrConcernRequest.h"

@implementation SaveFriendOrConcernRequest

- (instancetype)initWithHandleFriendId:(NSInteger)userId andIsAdd:(BOOL)isAdd
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"user/saveFriendOrConcern";
        
        [self setIntegerValue:userId forParamKey:@"friendId"];
        [self setIntegerValue:1 forParamKey:@"type"];
        
        if (isAdd) {
            [self setIntegerValue:1 forParamKey:@"subType"];
        }else{
            [self setIntegerValue:2 forParamKey:@"subType"];
        }
    }
    return self;
}

- (instancetype)initWithHandleConcernId:(NSInteger)userId andIsAdd:(BOOL)isAdd
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"user/saveFriendOrConcern";
        
        [self setIntegerValue:userId forParamKey:@"friendId"];
        [self setIntegerValue:2 forParamKey:@"type"];
        
        if (isAdd) {
            [self setIntegerValue:1 forParamKey:@"subType"];
        }else{
            [self setIntegerValue:2 forParamKey:@"subType"];
        }
    }
    return self;
}

@end
