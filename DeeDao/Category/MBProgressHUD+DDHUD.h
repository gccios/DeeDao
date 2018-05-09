//
//  MBProgressHUD+DDHUD.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (DDHUD)

+ (MBProgressHUD *)showLoadingHUDWithText:(NSString *)text inView:(UIView *)view;

+ (void)showTextHUDWithText:(NSString *)text inView:(UIView *)view;

@end
