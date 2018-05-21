//
//  DDHandleView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDHandleView.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>

@interface DDHandleView ()

@end

@implementation DDHandleView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createHandleView];
    }
    return self;
}

- (void)createHandleView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    self.backgroundColor = [UIColorFromRGB(0x000000) colorWithAlphaComponent:.4f];
    
    self.yaoyueButton = [DDHandleButton buttonWithType:UIButtonTypeCustom];
    [self.yaoyueButton configImage:[UIImage imageNamed:@"yaoyue"]];
    [self.yaoyueButton configTitle:@"99+"];
    self.yaoyueButton.handleLabel.textColor = UIColorFromRGB(0xFFFFFF);
    [self addSubview:self.yaoyueButton];
    [self.yaoyueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(42 * scale);
        make.centerY.mas_equalTo(5 * scale);
        make.width.height.mas_equalTo(96 * scale);
    }];
    
    self.shoucangButton = [DDHandleButton buttonWithType:UIButtonTypeCustom];
    [self.shoucangButton configImage:[UIImage imageNamed:@"yaoyue"]];
    [self.shoucangButton configTitle:@"99+"];
    self.shoucangButton.handleLabel.textColor = UIColorFromRGB(0xFFFFFF);
    [self addSubview:self.shoucangButton];
    [self.shoucangButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(390 * scale);
        make.centerY.mas_equalTo(self.yaoyueButton);
        make.width.height.mas_equalTo(96 * scale);
    }];
    
    self.dazhaohuButton = [DDHandleButton buttonWithType:UIButtonTypeCustom];
    [self.dazhaohuButton configImage:[UIImage imageNamed:@"dazhaohu"]];
    [self.dazhaohuButton configTitle:@"99+"];
    self.dazhaohuButton.handleLabel.textColor = UIColorFromRGB(0xFFFFFF);
    [self addSubview:self.dazhaohuButton];
    [self.dazhaohuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(738 * scale);
        make.centerY.mas_equalTo(self.shoucangButton);
        make.width.height.mas_equalTo(96 * scale);
    }];
    
    for (NSInteger i = 0; i < 3; i++) {
        for (NSInteger j = 2; j > -1; j--) {
            UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
            imageView.tag = i * 3 + j + 1;
            if (j % 3  == 1) {
                imageView.backgroundColor = UIColorFromRGB(0xDB6283);
            }else{
                imageView.backgroundColor = UIColorFromRGB(0XB721FF);
            }
            [self addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo((140 + i % 3 * 350 + j * 52) * scale);
                make.centerY.mas_equalTo(self.dazhaohuButton);
                make.width.height.mas_equalTo(96 * scale);
            }];
            [DDViewFactoryTool cornerRadius:48 * scale withView:imageView];
        }
    }
}


@end
