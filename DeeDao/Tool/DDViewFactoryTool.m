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

+ (UIImageView *)createImageViewWithFrame:(CGRect)frame contentModel:(UIViewContentMode)model image:(UIImage *)image
{
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.contentMode = model;
    [imageView setImage:image];
    return imageView;
}

+ (void)cornerRadius:(CGFloat)radius withView:(UIView *)view
{
    view.layer.cornerRadius = radius;
    view.layer.masksToBounds = YES;
}


+ (void)addBorderToLayer:(UIView *)view
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    CAShapeLayer *border = [CAShapeLayer layer];
    //  线条颜色
    border.strokeColor = UIColorFromRGB(0xDB6283).CGColor;
    
    border.fillColor = nil;
    
    border.path = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
    
    border.frame = view.bounds;
    
    // 不要设太大 不然看不出效果
    border.lineWidth = 3 * scale;
    
    border.lineCap = @"square";
    
    //  第一个是 线条长度   第二个是间距    nil时为实线
    border.lineDashPattern = @[@(3*scale), @(9*scale)];
    
    [view.layer addSublayer:border];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height); //宽高 1.0只要有值就够了
    UIGraphicsBeginImageContext(rect.size); //在这个范围内开启一段上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);//在这段上下文中获取到颜色UIColor
    CGContextFillRect(context, rect);//用这个颜色填充这个上下文
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();//从这段上下文中获取Image属性,,,结束
    UIGraphicsEndImageContext();
    
    return image;
}

@end
