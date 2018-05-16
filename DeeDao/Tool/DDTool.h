//
//  DDTool.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDTool : NSObject

+ (void)configApplication;

//获取当前13位时间戳
+(NSString *)getTimeStampMS;

+ (NSString *)getCurrentTimeWithFormat:(NSString *)format;

+ (NSString *)getImageURLWithHtml:(NSString *)html;

@end
