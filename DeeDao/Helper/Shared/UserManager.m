//
//  UserManager.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "UserManager.h"
#import <AFNetworking/AFNetworking.h>
#import "MBProgressHUD+DDHUD.h"

NSString * const DDUserDidLoginOutNotification = @"DDUserDidLoginOutNotification";

@implementation UserManager

+ (instancetype)shareManager
{
    static dispatch_once_t once;
    static UserManager * instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)loginWithDictionary:(NSDictionary *)userInfo
{
    self.user = [UserModel mj_objectWithKeyValues:userInfo];
    
    self.isLogin = YES;
}

- (BOOL)saveUserInfo
{
    NSDictionary * userInfo = [self.user mj_keyValues];
    
    NSLog(@"%@", DDUserInfoPath);
    return [userInfo writeToFile:DDUserInfoPath atomically:YES];
}

- (void)logoutAccount
{
    self.isLogin = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:DDUserInfoPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:DDUserInfoPath error:nil];
    }
}

@end
