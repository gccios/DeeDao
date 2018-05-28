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
#import <IQKeyboardManager.h>
#import <Photos/Photos.h>
#import "MBProgressHUD+DDHUD.h"

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
    
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
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

+ (double)getTimeCurrentWithDouble
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970] * 1000;
    return time;
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

+ (double)DDGetDoubleTimeWithDisYear:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day
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
    
    return [calculatedate timeIntervalSince1970] * 1000;
}

+ (double)DDGetDoubleWithYear:(NSInteger)year mouth:(NSInteger)mouth day:(NSInteger)day
{
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents* comp2 = [[NSDateComponents alloc]
                               init];
    // 设置各时间字段的数值
    comp2.year = year;
    comp2.month = mouth;
    comp2.day = day;
    comp2.hour = 0;
    comp2.minute = 0;
    // 通过NSDateComponents所包含的时间字段的数值来恢复NSDate对象
    NSDate *date = [gregorian dateFromComponents:comp2];
    
    return [date timeIntervalSince1970] * 1000;
}

+ (NSString *)getTimeWithFormat:(NSString *)format time:(NSInteger)time
{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:(double)time / 1000];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:date];
}

+ (CGFloat)getHeightByWidth:(CGFloat)width title:(NSString *)title font:(UIFont *)font
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    label.text = title;
    label.font = font;
    label.numberOfLines = 0;
    [label sizeToFit];
    CGFloat height = label.frame.size.height;
    return height;
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

+ (void)userLibraryAuthorizationStatusWithSuccess:(void (^)(void))success failure:(void (^)(void))failure
{
    //判断用户是否拥有权限
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    success();
                }else{
                    failure();
                }
            });
        }];
    } else if (status == PHAuthorizationStatusAuthorized) {
        dispatch_async(dispatch_get_main_queue(), ^{
            success();
        });
    } else{
        dispatch_async(dispatch_get_main_queue(), ^{
            failure();
        });
    }
}

+ (void)saveImageInSystemPhoto:(UIImage *)image
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        __block NSString *createdAssetId = nil;
        NSError * error;
        // 添加图片到【相机胶卷】
        // 同步方法,直接创建图片,代码执行完,图片没创建完,所以使用占位ID (createdAssetId)
        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            createdAssetId = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
        } error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [MBProgressHUD showTextHUDWithText:@"保存失败" inView:[UIApplication sharedApplication].keyWindow];
            }else{
                [MBProgressHUD showTextHUDWithText:@"保存成功" inView:[UIApplication sharedApplication].keyWindow];
            }
        });
    });
}

@end
