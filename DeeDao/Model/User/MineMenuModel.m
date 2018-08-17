//
//  MineMenuModel.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/10.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "MineMenuModel.h"

@implementation MineMenuModel

- (instancetype)initWithType:(MineMenuType)type
{
    if (self = [super init]) {
        
        self.type = type;
        
        switch (type) {
            case MineMenuType_Wallet:
                
            {
                self.imageName = @"wallet";
                self.title = @"我的钱包";
            }
                
                break;
                
            case MineMenuType_Achievement:
                
            {
                self.imageName = @"achievement";
                self.title = @"我的成就";
            }
                
                break;
                
            case MineMenuType_Address:
                
            {
                self.imageName = @"address";
                self.title = @"关系列表";
            }
                
                break;
                
            case MineMenuType_Private:
                
            {
                self.imageName = @"private";
                self.title = @"管理我的好友圈";
            }
                
                break;
                
            case MineMenuType_System:
                
            {
                self.imageName = @"system";
                self.title = @"系统设置";
            }
                
                break;
                
            case MineMenuType_Blogger:
                
            {
                self.imageName = @"achievement";
                self.title = @"博主链接";
            }
                
                break;
                
            case MineMenuType_AlertList:
                
            {
                self.imageName = @"achievement";
                self.title = @"提醒记录设置";
            }
                
                break;
                
            case MineMenuType_HandleGuide:
                
            {
                self.imageName = @"achievement";
                self.title = @"操作引导";
            }
                
                break;
                
            default:
                break;
        }
        
    }
    return self;
}

@end
