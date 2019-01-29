//
//  DDGroupModel.m
//  DeeDao
//
//  Created by 郭春城 on 2019/1/10.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DDGroupModel.h"
#import "UserManager.h"

@implementation DDGroupModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"cid" : @"id",//前边的是你想用的key，后边的是返回的key
             @"remark" : @"description"
             };
}

- (instancetype)initWithMy
{
    if (self = [super init]) {
        self.cid = -1;
        self.groupName = @"我的打卡";
        self.groupPic = [UserManager shareManager].user.portraituri;
        self.remark = @"系统默认群，包含我的帖子";
        self.groupCreateDate = [UserManager shareManager].user.createdat;
        self.isSystem = YES;
    }
    return self;
}

- (instancetype)initWithPublic
{
    if (self = [super init]) {
        self.cid = -2;
        self.groupName = @"地到公开";
        self.groupPic = @"PublicDefault";
        self.remark = @"系统默认群，包含所有的公开帖";
        self.groupCreateDate = [UserManager shareManager].user.createdat;
        self.isSystem = YES;
    }
    return self;
}

- (instancetype)initWithMyCollect
{
    if (self = [super init]) {
        self.cid = -4;
        self.groupName = @"我的收藏";
        self.groupPic = [UserManager shareManager].user.portraituri;
        self.remark = @"系统默认群，包含所有我的收藏帖";
        self.groupCreateDate = [UserManager shareManager].user.createdat;
        self.isSystem = YES;
    }
    return self;
}


- (instancetype)initWithMyWYY
{
    if (self = [super init]) {
        self.cid = -5;
        self.groupName = @"我的约帖";
        self.groupPic = [UserManager shareManager].user.portraituri;
        self.remark = @"系统默认群，包含所有我的组局帖";
        self.groupCreateDate = [UserManager shareManager].user.createdat;
        self.isSystem = YES;
    }
    return self;
}

- (instancetype)initWithMyHome
{
    if (self = [super init]) {
        self.cid = -6;
        self.groupName = @"首页";
        self.groupPic = [UserManager shareManager].user.portraituri;
        self.remark = @"系统默认群，包含所有我可以查看的帖子";
        self.groupCreateDate = [UserManager shareManager].user.createdat;
        self.isSystem = YES;
    }
    return self;
}

- (instancetype)initWithCreate
{
    if (self = [super init]) {
        self.cid = -3;
        self.groupName = @"新建一个群";
        self.groupPic = @"PDQuanbu";
        self.isSystem = YES;
    }
    return self;
}

@end
