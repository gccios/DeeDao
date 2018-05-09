//
//  MBProgressHUD+DDHUD.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "MBProgressHUD+DDHUD.h"
#import <Masonry/Masonry.h>

@implementation MBProgressHUD (DDHUD)

+ (MBProgressHUD *)showLoadingHUDWithText:(NSString *)text inView:(UIView *)view
{
    [UIActivityIndicatorView appearanceWhenContainedIn:[MBProgressHUD class], nil].color = [UIColor whiteColor];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:.7f];
    hud.label.font = kPingFangRegular(15);
    hud.label.textColor = [UIColor whiteColor];
    hud.bezelView.layer.cornerRadius = 8;
    hud.minSize = CGSizeMake(kMainBoundsWidth / 3.3, kMainBoundsWidth / 3.3);
    hud.label.text = text;
    
    return hud;
}

+ (void)showTextHUDWithText:(NSString *)text inView:(UIView *)view
{
    if (isEmptyString(text)) {
        return;
    }
    
    UIView * tempView = [[UIApplication sharedApplication].keyWindow viewWithTag:677];
    if (tempView) {
        [tempView removeFromSuperview];
    }
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(view.frame.size.width - 60, 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:kPingFangLight(17)} context:nil];
    
    UIView * backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width + 30, rect.size.height + 20)];
    backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.75f];
    backView.layer.cornerRadius = 5.f;
    backView.clipsToBounds = YES;
    backView.tag = 677;
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width + 10, rect.size.height + 10)];
    label.numberOfLines = 0;
    label.textColor = [UIColor whiteColor];
    label.text = text;
    label.backgroundColor = [UIColor clearColor];
    label.userInteractionEnabled = YES;
    label.center = CGPointMake(backView.frame.size.width / 2, backView.frame.size.height / 2);
    label.textAlignment = NSTextAlignmentCenter;
    label.font = kPingFangLight(17);
    
    [view addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(rect.size.width + 30);
        make.height.mas_equalTo(rect.size.height + 20);
        make.center.mas_equalTo(0);
    }];
    
    [backView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(rect.size.width + 10);
        make.height.mas_equalTo(rect.size.height + 10);
        make.center.mas_equalTo(0);
    }];
    
    backView.alpha = 0.f;
    [UIView animateWithDuration:.2f animations:^{
        backView.alpha = 1.f;
    }];
    
    [UIView animateWithDuration:0.5f delay:1.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        backView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [backView removeFromSuperview];
    }];
}

@end
