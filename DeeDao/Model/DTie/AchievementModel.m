//
//  AchievementModel.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "AchievementModel.h"

@implementation AchievementModel

+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"details":@"DTieEditModel"};
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"cid" : @"id"//前边的是你想用的key，后边的是返回的key
             };
}

@end
