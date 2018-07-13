//
//  UserInfoViewController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"
#import "UserModel.h"

@protocol UserFriendInfoDelegate <NSObject>

- (void)userFriendInfoDidUpdate:(UserModel *)model;

@end

@interface UserInfoViewController : DDViewController

@property (nonatomic, weak) id<UserFriendInfoDelegate> delegate;

- (instancetype)initWithUserId:(NSInteger)userId;

@end
