//
//  UserYaoYueModel.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/13.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "UserYaoYueModel.h"

@implementation UserYaoYueModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"cid" : @"id"//前边的是你想用的key，后边的是返回的key
             };
}

- (void)setPortraituri:(NSString *)portraituri
{
    if (isEmptyString(portraituri)) {
        _portraituri = @"http://ow57gfs34.bkt.clouddn.com/DefaultLogo/defalutLogo.png";
    }else{
        _portraituri = portraituri;
    }
}

- (void)setPortrait:(NSString *)portrait
{
    if (isEmptyString(portrait)) {
        _portraituri = @"http://ow57gfs34.bkt.clouddn.com/DefaultLogo/defalutLogo.png";
    }else{
        _portraituri = portrait;
    }
}

- (void)setNickname:(NSString *)nickName
{
    _nickname = [self replaceUnicode:nickName];
}

- (NSString *)replaceUnicode:(NSString *)unicodeStr
{
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2]stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}

@end
