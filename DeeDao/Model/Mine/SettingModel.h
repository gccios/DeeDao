//
//  SettingModel.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/19.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    SettingType_Collect,
    SettingType_ArriveCollect,
    SettingType_ArriveFollow,
    SettingType_SayHello,
    SettingType_Thank,
    SettingType_AlertTip,
    SettingType_Message
} SettingType;

@interface SettingModel : NSObject

- (instancetype)initWithType:(SettingType)type;

@property (nonatomic, copy) NSString * title;
@property (nonatomic, assign) BOOL status;
@property (nonatomic, assign) SettingType type;
@property (nonatomic, copy) NSString * systemKey;

@end
