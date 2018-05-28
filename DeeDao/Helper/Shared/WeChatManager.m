//
//  WeChatManager.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "WeChatManager.h"
#import "DDActivityViewController.h"
#import "MBProgressHUD+DDHUD.h"

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

- (void)shareTimeLineWithImages:(NSArray *)images title:(NSString *)title viewController:(UIViewController *)viewController
{
    
    NSMutableArray * tempArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < images.count; i++) {
        UIImage * image = [images objectAtIndex:i];
        NSData*  data = [NSData data];
        data = UIImageJPEGRepresentation(image, 1);
        float tempX = 0.9;
        NSInteger length = data.length;
        while (data.length > 100*1024) {
            data = UIImageJPEGRepresentation(image, tempX);
            tempX -= 0.1;
            if (data.length == length) {
                break;
            }
            length = data.length;
        }
        [tempArray addObject:[UIImage imageWithData:data]];
    }
    
    
    DDActivityViewController * activityView = [[DDActivityViewController alloc] initWithActivityItems:tempArray applicationActivities:nil];
    activityView.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        if (activityError) {
            [MBProgressHUD showTextHUDWithText:@"分享失败" inView:viewController.view];
        }else{
            if (completed) {
                [MBProgressHUD showTextHUDWithText:@"分享成功" inView:viewController.view];
            }else{
                [MBProgressHUD showTextHUDWithText:@"分享失败" inView:viewController.view];
            }
        }
    };
    
    [viewController presentViewController:activityView animated:YES completion:nil];
}

- (void)onResp:(BaseResp *)resp
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DDUserDidGetWeChatCodeNotification object:resp];
}

@end
