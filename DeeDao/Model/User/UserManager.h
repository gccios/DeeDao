//
//  UserManager.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"

@interface UserManager : NSObject

@property (nonatomic, assign) BOOL isLogin;

@property (nonatomic, strong) UserModel * user;

+ (instancetype)shareManager;

- (void)loginWithDictionary:(NSDictionary *)userInfo;

- (void)logoutAccount;

- (BOOL)saveUserInfo;

@end
