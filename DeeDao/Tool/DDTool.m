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
#import <SDWebImageManager.h>
#import "WeChatManager.h"
#import "DDLocationManager.h"
#import "ApplicationConfigRequest.h"
#import "BaiduMobStat.h"
#import "DTieDetailRequest.h"
#import "DTieNewDetailViewController.h"
#import "DDLGSideViewController.h"

@implementation DDTool

+ (void)configApplication
{
    [[BGNetworkManager sharedManager] setNetworkConfiguration:[DDNetworkConfiguration configuration]];
    
    [WXApi registerApp:WeChatAPPKey];
    
    [[BaiduMobStat defaultStat] startWithAppId:BaiDuAppKey];
    
    // 设置通知的类型可以为弹窗提示,声音提示,应用图标数字提示
    UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
    // 授权通知
    [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    
//    配置用户信息
//    if ([[NSFileManager defaultManager] fileExistsAtPath:DDUserInfoPath]) {
//        NSDictionary * userInfo = [NSDictionary dictionaryWithContentsOfFile:DDUserInfoPath];
//        if (userInfo && [userInfo isKindOfClass:[NSDictionary class]]) {
//            
//            [[UserManager shareManager] loginWithDictionary:userInfo];
//            
//        }else {
//            
//        }
//    }
    
    [[UITableView appearance] setEstimatedRowHeight:0];
    [[UITableView appearance] setEstimatedSectionFooterHeight:0];
    [[UITableView appearance] setEstimatedSectionHeaderHeight:0];
    
    //设置图片缓存策略
    [[SDImageCache sharedImageCache].config setShouldDecompressImages:NO];
    [[SDWebImageDownloader sharedDownloader] setShouldDecompressImages:NO];
    
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
    
    [self getApplicationConfigFromSever];
}

+ (void)getApplicationConfigFromSever
{
    ApplicationConfigRequest * request = [[ApplicationConfigRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                NSInteger distance = [[data objectForKey:@"distance"] integerValue];
                if (distance > 0) {
                    [DDLocationManager shareManager].distance = distance;
                }
                
                NSArray * titleList = [data objectForKey:@"random"];
                if (KIsArray(titleList)) {
                    [[WeChatManager shareManager].titleList addObjectsFromArray:titleList];
                }
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
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
    [formatter setDateFormat:@"yyyy年MM月dd日"];
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

+ (double)DDGetDoubleWithYear:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day hour:(NSInteger)hour minute:(NSInteger)minute
{
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    
    NSDateComponents* comp2 = [[NSDateComponents alloc]
                               init];
    // 设置各时间字段的数值
    comp2.year = year;
    comp2.month = month;
    comp2.day = day;
    comp2.hour = hour;
    comp2.minute = minute;
    // 通过NSDateComponents所包含的时间字段的数值来恢复NSDate对象
    NSDate *date = [gregorian dateFromComponents:comp2];
    NSTimeInterval time = [date timeIntervalSince1970];
    
    return time * 1000;
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
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:title];
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = 6; //设置行间距
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@1.5f
                          };
    [attributeString addAttributes:dic range:NSMakeRange(0, attributeString.length)];
    CGSize size = [attributeString boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    return size.height;
}

+ (NSString *)getImageURLWithHtml:(NSString *)html
{
    NSString * str = [html stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray * array = [html componentsSeparatedByString:@"src=\""];
    if (array.count == 1) {
        return str;
    }
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
    NSString * str = [html stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSArray * array = [html componentsSeparatedByString:@"</font"];
    if (array.count == 1) {
        return str;
    }
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

+ (void)saveImageInSystemPhotoWithNoHUD:(UIImage *)image
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
                
            }else{
                
            }
        });
    });
}

+ (NSString *)replaceUnicode:(NSString *)unicodeStr
{
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2]stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}

+ (CGFloat)getHeightWithImage:(UIImage *)image
{
    if (nil == image) {
        return .1f;
    }
    
    CGFloat scale = image.size.height / image.size.width;
    CGFloat height = kMainBoundsWidth * scale;
    return height;
}

+ (void)WXMiniProgramHandleWithPostID:(NSInteger)postID
{
    [WeChatManager shareManager].miniProgramPostID = postID;
    if (postID == 0) {
        return;
    }
    
    if ([UserManager shareManager].isLogin) {
        [WeChatManager shareManager].miniProgramPostID = 0;
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:[UIApplication sharedApplication].keyWindow];
        
        DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:postID type:4 start:0 length:10];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
            
            if (KIsDictionary(response)) {
                
                NSInteger code = [[response objectForKey:@"status"] integerValue];
                if (code == 4002) {
                    [MBProgressHUD showTextHUDWithText:@"该帖已被作者删除~" inView:[UIApplication sharedApplication].keyWindow];
                    return;
                }
                
                NSDictionary * data = [response objectForKey:@"data"];
                if (KIsDictionary(data)) {
                    DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
                    
                    if (dtieModel.deleteFlg == 1) {
                        [MBProgressHUD showTextHUDWithText:@"该帖已被作者删除~" inView:[UIApplication sharedApplication].keyWindow];
                        return;
                    }
                    DTieNewDetailViewController * detail = [[DTieNewDetailViewController alloc] initWithDTie:dtieModel];
                    
                    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                    UINavigationController * na = (UINavigationController *)lg.rootViewController;
                    if (na && [na isKindOfClass:[UINavigationController class]]) {
                        [na pushViewController:detail animated:YES];
                    }
                }
            }
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            [hud hideAnimated:YES];
        }];
    }
}

@end
