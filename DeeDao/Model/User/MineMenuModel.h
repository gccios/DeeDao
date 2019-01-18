//
//  MineMenuModel.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/10.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MineMenuType_Wallet,
    MineMenuType_Achievement,
    MineMenuType_Address,
    MineMenuType_Private,
    MineMenuType_System,
    MineMenuType_Blogger,
    MineMenuType_AlertList,
    MineMenuType_HandleGuide,
    MineMenuType_shareMingPian,
    MineMenuType_hudongMessage,
    MineMenuType_FriendCard,
    MineMenuType_SystemMnager,
    MineMenuType_MYHome
} MineMenuType;

@interface MineMenuModel : NSObject

@property (nonatomic, assign) MineMenuType type;
@property (nonatomic, copy) NSString * imageName;
@property (nonatomic, copy) NSString * title;

- (instancetype)initWithType:(MineMenuType)type;

@end
