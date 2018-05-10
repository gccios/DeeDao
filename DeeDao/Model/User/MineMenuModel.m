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
                self.title = @"我的通讯录";
            }
                
                break;
                
            case MineMenuType_Private:
                
            {
                self.imageName = @"private";
                self.title = @"管理我的小密圈";
            }
                
                break;
                
            case MineMenuType_System:
                
            {
                self.imageName = @"system";
                self.title = @"系统设置";
            }
                
                break;
                
            default:
                break;
        }
        
    }
    return self;
}

@end
