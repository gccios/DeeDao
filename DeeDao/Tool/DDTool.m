//
//  DDTool.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDTool.h"
#import <UMShare/UMSocialManager.h>

@implementation DDTool

+ (void)configApplication
{
    [[UMSocialManager defaultManager] setUmSocialAppkey:UMAppKey];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:WeChatAPPKey appSecret:WeChatAPPSecret redirectURL:@"http://mobile.umeng.com/social"];
}

@end
