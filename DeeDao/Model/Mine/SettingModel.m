//
//  SettingModel.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/19.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SettingModel.h"

#define SettingCollect @"SettingCollect"
#define SettingArriveCollect @"SettingArriveCollect"
#define SettingArriveFollow @"SettingArriveFollow"
#define SettingSayHello @"SettingSayHello"
#define SettingThank @"SettingThank"
#define SettingMessage @"SettingMessage"

@implementation SettingModel

- (instancetype)initWithType:(SettingType)type
{
    if (self = [super init]) {
        
        self.type = type;
        switch (type) {
            case SettingType_Collect:
            {
                self.title = @"D帖/系列被收藏提示";
                self.status = [DDUserDefaultsGet(SettingCollect) boolValue];
                self.systemKey = SettingCollect;
            }
                break;
                
            case SettingType_ArriveCollect:
            {
                self.title = @"到达收藏用户D帖附近提示";
                self.status = [DDUserDefaultsGet(SettingArriveCollect) boolValue];
                self.systemKey = SettingArriveCollect;
            }
                
                break;
                
            case SettingType_ArriveFollow:
            {
                self.title = @"到达关注用户D帖附近提示";
                self.status = [DDUserDefaultsGet(SettingArriveFollow) boolValue];
                self.systemKey = SettingArriveFollow;
            }
                
                break;
                
            case SettingType_SayHello:
            {
                self.title = @"被打招呼提示";
                self.status = [DDUserDefaultsGet(SettingSayHello) boolValue];
                self.systemKey = SettingSayHello;
            }
                
                break;
                
            case SettingType_Thank:
            {
                self.title = @"被感谢提示";
                self.status = [DDUserDefaultsGet(SettingThank) boolValue];
                self.systemKey = SettingThank;
            }
                
                break;
                
            case SettingType_Message:
            {
                self.title = @"收到留言提示";
                self.status = [DDUserDefaultsGet(SettingMessage) boolValue];
                self.systemKey = SettingMessage;
            }
                
                break;
                
            default:
                break;
        }
        
    }
    return self;
}

@end
