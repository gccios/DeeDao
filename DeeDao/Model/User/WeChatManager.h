//
//  WeChatManager.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WXApi.h>

extern NSString * const DDUserDidGetWeChatCodeNotification; //用户登录成功通知

@interface WeChatManager : NSObject <WXApiDelegate>

+ (instancetype)shareManager;

- (void)loginWithWeChat;

@end
