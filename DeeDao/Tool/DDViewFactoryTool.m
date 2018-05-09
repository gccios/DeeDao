//
//  DDViewFactoryTool.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewFactoryTool.h"

@implementation DDViewFactoryTool

+ (UILabel *)createLabelWithFrame:(CGRect)frame font:(UIFont *)font textColor:(UIColor *)textColor alignment:(NSTextAlignment)alignment
{
    UILabel * label = [[UILabel alloc] initWithFrame:frame];
    label.font = font;
    label.textColor = textColor;
    label.textAlignment = alignment;
    return label;
}

+ (UILabel *)createLabelWithFrame:(CGRect)frame font:(UIFont *)font textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor alignment:(NSTextAlignment)alignment
{
    UILabel * label = [self createLabelWithFrame:frame font:font textColor:textColor alignment:alignment];
    label.backgroundColor = backgroundColor;
    
    return label;
}

+ (UIButton *)createButtonWithFrame:(CGRect)frame font:(UIFont *)font titleColor:(UIColor *)titleColor title:(NSString *)title
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    button.titleLabel.font = font;
    [button setTitle:title forState:UIControlStateNormal];
    return button;
}

+ (UIButton *)createButtonWithFrame:(CGRect)frame font:(UIFont *)font titleColor:(UIColor *)titleColor backgroundColor:(UIColor *)backgroundColor title:(NSString *)title
{
    UIButton * button = [self createButtonWithFrame:frame font:font titleColor:titleColor title:title];
    button.backgroundColor = backgroundColor;
    return button;
}

+ (void)cornerRadius:(CGFloat)radius withView:(UIView *)view
{
    view.layer.cornerRadius = radius;
    view.layer.masksToBounds = YES;
}

@end
