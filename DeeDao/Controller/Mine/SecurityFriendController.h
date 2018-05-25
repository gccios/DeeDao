//
//  SecurityFriendController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"

@class UserModel;
@protocol SecurityFriendDelegate <NSObject>

- (void)securityFriendDidSelectWith:(UserModel *)model;

@end

@interface SecurityFriendController : DDViewController

@property (nonatomic, weak) id<SecurityFriendDelegate> delegate;

- (instancetype)initWithDataDict:(NSDictionary *)dataDict nameKeys:(NSArray *)nameKeys;

@end
