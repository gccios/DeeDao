//
//  DDViewFactoryTool.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDViewFactoryTool : NSObject

+ (UILabel *)createLabelWithFrame:(CGRect)frame font:(UIFont *)font textColor:(UIColor *)textColor alignment:(NSTextAlignment)alignment;

+ (UILabel *)createLabelWithFrame:(CGRect)frame font:(UIFont *)font textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor alignment:(NSTextAlignment)alignment;

+ (UIButton *)createButtonWithFrame:(CGRect)frame font:(UIFont *)font titleColor:(UIColor *)titleColor title:(NSString *)title;

+ (UIButton *)createButtonWithFrame:(CGRect)frame font:(UIFont *)font titleColor:(UIColor *)titleColor backgroundColor:(UIColor *)backgroundColor title:(NSString *)title;

+ (UIImageView *)createImageViewWithFrame:(CGRect)frame contentModel:(UIViewContentMode)model image:(UIImage *)image;

+ (void)cornerRadius:(CGFloat)radius withView:(UIView *)view;

@end
