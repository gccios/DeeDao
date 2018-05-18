//
//  DDTool.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDTool.h"
#import "UserManager.h"
#import <WXApi.h>
#import <BGNetworkManager.h>
#import "DDNetworkConfiguration.h"

@implementation DDTool

+ (void)configApplication
{
    [[BGNetworkManager sharedManager] setNetworkConfiguration:[DDNetworkConfiguration configuration]];
    
    [WXApi registerApp:WeChatAPPKey];
    
    //配置用户信息
    if ([[NSFileManager defaultManager] fileExistsAtPath:DDUserInfoPath]) {
        NSDictionary * userInfo = [NSDictionary dictionaryWithContentsOfFile:DDUserInfoPath];
        if (userInfo && [userInfo isKindOfClass:[NSDictionary class]]) {
            
            [[UserManager shareManager] loginWithDictionary:userInfo];
            
        }else {
            
        }
    }
    
    [[UITableView appearance] setEstimatedRowHeight:0];
    [[UITableView appearance] setEstimatedSectionFooterHeight:0];
    [[UITableView appearance] setEstimatedSectionHeaderHeight:0];
}

+ (NSString *)getTimeStampMS
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

+ (NSString *)getCurrentTimeWithFormat:(NSString *)format
{
    NSDate * date = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:date];
}

///< 获取当前时间的: 前一周(day:-7)丶前一个月(month:-30)丶前一年(year:-1)的时间
+ (NSString *)DDGetExpectTimeYear:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day
{
    ///< 当前时间
    NSDate *currentdata = [NSDate date];
    
    ///< NSCalendar -- 日历类，它提供了大部分的日期计算接口，并且允许您在NSDate和NSDateComponents之间转换
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *datecomps = [[NSDateComponents alloc] init];
    [datecomps setYear:year?:0];
    [datecomps setMonth:month?:0];
    [datecomps setDay:day?:0];
    
    ///< dateByAddingComponents: 在参数date基础上，增加一个NSDateComponents类型的时间增量
    NSDate *calculatedate = [calendar dateByAddingComponents:datecomps toDate:currentdata options:0];
    
    ///< 打印推算时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *calculateStr = [formatter stringFromDate:calculatedate];
    
    return calculateStr;
}  

+ (NSString *)getTimeWithFormat:(NSString *)format time:(NSInteger)time
{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:(double)time / 1000];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:date];
}

+ (NSString *)getImageURLWithHtml:(NSString *)html
{
    NSString * str;
    NSArray * array = [html componentsSeparatedByString:@"src=\""];
    str = array.lastObject;
    NSArray * resultArray = [str componentsSeparatedByString:@"\""];
    str = resultArray.firstObject;
    if (isEmptyString(str)) {
        str = @"";
    }
    return str;
}

+ (NSString *)getTextWithHtml:(NSString *)html
{
    NSString * str;
    
    NSArray * array = [html componentsSeparatedByString:@"</font"];
    str = array.firstObject;
    NSArray * tempArray = [str componentsSeparatedByString:@"<font"];
    str = tempArray.lastObject;
    NSArray * resultArray = [str componentsSeparatedByString:@">"];
    str = resultArray.lastObject;
    
    if (isEmptyString(str)) {
        str = @"";
    }
    return str;
}

@end
