//
//  WeChatManager.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserManager.h"
#import <WXApi.h>

extern NSString * const DDUserDidGetWeChatCodeNotification; //用户登录成功通知
extern NSString * const DDUserDidLoginWithTelNumberNotification; //用户登录成功通知

@interface WeChatManager : NSObject <WXApiDelegate>

@property (nonatomic, assign) BOOL isShare;

@property (nonatomic, strong) NSMutableArray * titleList;

@property (nonatomic, copy) NSString * miniProgramToken;

@property (nonatomic, assign) NSInteger miniProgramPostID;

+ (instancetype)shareManager;

- (void)loginWithWeChat;

- (void)shareTimeLineWithImages:(NSArray *)images title:(NSString *)title viewController:(UIViewController *)viewController;

- (void)savePhotoWithImages:(NSArray *)images title:(NSString *)title viewController:(UIViewController *)viewController;

- (void)shareMiniProgramWithPostID:(NSInteger)postID image:(UIImage *)image isShare:(BOOL)isShare title:(NSString *)title;

- (void)shareMiniProgramWithUser:(UserModel *)model;

- (void)getMiniProgromCodeWithPostID:(NSInteger)postID handle:(void (^)(UIImage * image))handle;
- (void)getMiniProgromCodeWithUserID:(NSInteger)userID handle:(void (^)(UIImage * image))handle;

- (void)shareImage:(UIImage *)image;

- (void)shareFriendImage:(UIImage *)image;

- (void)shareToBiz;

@end
