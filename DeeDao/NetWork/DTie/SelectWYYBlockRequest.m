//
//  SelectWYYBlockRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SelectWYYBlockRequest.h"

@implementation SelectWYYBlockRequest

- (instancetype)initWithPostID:(NSInteger)postID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = [NSString stringWithFormat:@"post/selectWYYBlock/%ld", postID];
    }
    return self;
}

- (instancetype)initSwitchWithPostID:(NSInteger)postID status:(BOOL)status
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/uploadPicSwitch";
        
        [self setIntegerValue:postID forParamKey:@"postId"];
        if (status) {
            [self setIntegerValue:1 forParamKey:@"switchStatus"];
        }else{
            [self setIntegerValue:0 forParamKey:@"switchStatus"];
        }
        
    }
    return self;
}

- (instancetype)initAddUserSwitchWithPostID:(NSInteger)postID status:(BOOL)status
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/wyyPermissionSwitch";
        
        [self setIntegerValue:postID forParamKey:@"postId"];
        if (status) {
            [self setIntegerValue:1 forParamKey:@"wYYPermission"];
        }else{
            [self setIntegerValue:0 forParamKey:@"wYYPermission"];
        }
        
    }
    return self;
}

@end
