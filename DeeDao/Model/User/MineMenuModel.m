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
                self.imageName = @"chengjiurukou";
                self.title = DDLocalizedString(@"My treasure");
            }
                
                break;
                
            case MineMenuType_Address:
                
            {
                self.imageName = @"address";
                self.title = DDLocalizedString(@"ConnectionsList");
            }
                
                break;
                
            case MineMenuType_Private:
                
            {
                self.imageName = @"private";
                self.title = DDLocalizedString(@"Network circles");
            }
                
                break;
                
            case MineMenuType_System:
                
            {
                self.imageName = @"system";
                self.title = DDLocalizedString(@"Settings");
            }
                
                break;
                
            case MineMenuType_Blogger:
                
            {
                self.imageName = @"achievement";
                self.title = DDLocalizedString(@"BloggerLink");
            }
                
                break;
                
            case MineMenuType_AlertList:
                
            {
                self.imageName = @"alertList";
                self.title = DDLocalizedString(@"Reminder history");
            }
                
                break;
                
            case MineMenuType_HandleGuide:
                
            {
                self.imageName = @"achievement";
                self.title = @"操作引导";
            }
                
                break;
                
            case MineMenuType_shareMingPian:
                
            {
                self.imageName = @"leftMingPian";
                self.title = DDLocalizedString(@"ShareCard");
            }
                
                break;
                
            case MineMenuType_hudongMessage:
                
            {
                self.imageName = @"leftMessage";
                self.title = DDLocalizedString(@"HudongMessage");
            }
                
                break;
                
            case MineMenuType_FriendCard:
                
            {
                self.imageName = @"alertList";
                self.title = DDLocalizedString(@"InvitesAndCards");
            }
                
                break;
                
            default:
                break;
        }
        
    }
    return self;
}

@end
