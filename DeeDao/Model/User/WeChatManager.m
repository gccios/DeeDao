//
//  WeChatManager.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "WeChatManager.h"

NSString * const DDUserDidGetWeChatCodeNotification = @"DDUserDidGetWeChatCodeNotification";

@implementation WeChatManager

+ (instancetype)shareManager
{
    static dispatch_once_t once;
    static WeChatManager * instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)loginWithWeChat
{
    //构造SendAuthReq结构体
    SendAuthReq* req =[[SendAuthReq alloc]init];
    req.scope = @"snsapi_userinfo";
    req.state = @"com.deedao.appstore";
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}

- (void)onResp:(BaseResp *)resp
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DDUserDidGetWeChatCodeNotification object:resp];
}

@end
