//
//  DDTool.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDTool : NSObject

+ (void)configApplication;

//获取当前13位时间戳
+(NSString *)getTimeStampMS;
+(double)getTimeCurrentWithDouble;

+ (NSString *)getCurrentTimeWithFormat:(NSString *)format;

+ (NSString *)DDGetExpectTimeYear:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day;
+ (double)DDGetDoubleTimeWithDisYear:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day;

+ (double)DDGetDoubleWithYear:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day hour:(NSInteger)hour minute:(NSInteger)minute;
+ (double)DDGetDoubleWithYear:(NSInteger)year mouth:(NSInteger)mouth day:(NSInteger)day;

+ (NSString *)getTimeWithFormat:(NSString *)format time:(NSInteger)time;

+ (CGFloat)getHeightByWidth:(CGFloat)width title:(NSString *)title font:(UIFont *)font;

+ (NSString *)getImageURLWithHtml:(NSString *)html;

+ (NSString *)getTextWithHtml:(NSString *)html;

+ (void)userLibraryAuthorizationStatusWithSuccess:(void (^)(void))success failure:(void (^)(void))failure;

+ (void)saveImageInSystemPhoto:(UIImage *)image;

+ (NSString *)replaceUnicode:(NSString *)unicodeStr;

@end
