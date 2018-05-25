//
//  MailModel.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/18.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "MailModel.h"

@implementation MailModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"cid" : @"id"//前边的是你想用的key，后边的是返回的key
             };
}

- (void)setMailTypeId:(NSInteger)mailTypeId
{
    _mailTypeId = mailTypeId;
    if (mailTypeId == 1 || mailTypeId == 2 ||mailTypeId == 8 ||mailTypeId == 9) {
        self.type = MailModelType_System;
    }else if (mailTypeId == 3 || mailTypeId == 4 ||mailTypeId == 5 ||mailTypeId == 7) {
        self.type = MailModelType_HuDong;
    }else if (mailTypeId == 6 || mailTypeId == 10 ||mailTypeId == 11) {
        self.type = MailModelType_DTie;
    }else{
        self.type = MailModelType_Other;
    }
}

- (void)setNickName:(NSString *)nickName
{
    _nickName = [self replaceUnicode:nickName];
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

+ (NSString *)getTitleWithMailTypeId:(NSInteger)typeId
{
    NSString * result = @"";
    
    switch (typeId) {
        case 1:
            result = @"转发了您的帖子";
            break;
            
        case 2:
            result = @"转发了您的系列";
            break;
            
        case 3:
            result = @"收藏了您的D贴";
            break;
            
        case 4:
            result = @"表示我要约";
            break;
            
        case 5:
            result = @"在D贴的位置向您打招呼";
            break;
            
        case 6:
            result = @"被感谢";
            break;
            
        case 7:
            result = @"一条新的推荐";
            break;
            
        case 8:
            result = @"请求添加您为好友";
            break;
            
        case 9:
            result = @"同意了您的好友请求";
            break;
            
        case 10:
            result = @"新留言";
            break;
            
        default:
            break;
    }
    return result;
}

@end
