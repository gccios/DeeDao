//
//  GuidePageView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/11.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "GuidePageView.h"
#import "DDViewFactoryTool.h"
#import "MBProgressHUD+DDHUD.h"
#import "SettingModel.h"
#import <Masonry.h>

@interface GuidePageView ()

@property (nonatomic, assign) NSInteger pageIndex;

@end

@implementation GuidePageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createFirstGuidePage];
    }
    return self;
}

#pragma mark - 第一页引导
- (void)createFirstGuidePage
{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    
    self.pageIndex = 1;
    
    CGFloat width = kMainBoundsWidth / 5 * 3;
    CGFloat scale = kMainBoundsWidth / 1080.f;
    UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFit image:[UIImage imageNamed:@"page1-1"]];
    [self addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(396.f / 672.f * width);
    }];
    
    UIButton * leftButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"page1-2"] forState:UIControlStateNormal];
    [self addSubview:leftButton];
    [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom).offset(40 * scale);
        make.left.mas_equalTo(imageView);
        make.width.mas_equalTo(263 * scale);
        make.height.mas_equalTo(96 * scale);
    }];
    [leftButton addTarget:self action:@selector(endGuide) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * rightButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"page1-3"] forState:UIControlStateNormal];
    [self addSubview:rightButton];
    [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom).offset(40 * scale);
        make.right.mas_equalTo(imageView);
        make.width.mas_equalTo(263 * scale);
        make.height.mas_equalTo(96 * scale);
    }];
    [rightButton addTarget:self action:@selector(nextGuide) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 第二页引导
- (void)createSecondGuide
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.pageIndex = 2;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nextGuide)];
    [self addGestureRecognizer:tap];
    
    CGFloat width = kMainBoundsWidth / 5 * 4;
    CGFloat scale = kMainBoundsWidth / 1080.f;
    UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFit image:[UIImage imageNamed:@"page2-1"]];
    [self addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(140 * scale);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(198.f / 241.f * width);
    }];
    
    width = kMainBoundsWidth / 7 * 5;
    UIImageView * bottomImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFit image:[UIImage imageNamed:@"page2-2"]];
    [self addSubview:bottomImageView];
    [bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-5 * scale);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(158.f / 241.f * width);
    }];
}

#pragma mark - 第三页引导
- (void)createThirdGuide
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.pageIndex = 3;
    
    CGFloat width = kMainBoundsWidth / 5 * 4;
    CGFloat scale = kMainBoundsWidth / 1080.f;
    UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFit image:[UIImage imageNamed:@"page3"]];
    [self addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-15 * scale);
        make.centerX.mas_equalTo(-30 * scale);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(176.f / 288.f * width);
    }];
}

#pragma mark - 第四页引导
- (void)createFourthGuide
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.pageIndex = 4;
    
    CGFloat width = kMainBoundsWidth / 5 * 4;
    CGFloat scale = kMainBoundsWidth / 1080.f;
    UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFit image:[UIImage imageNamed:@"page4"]];
    [self addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-15 * scale);
        make.centerX.mas_equalTo(27 * scale);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(176.f / 288.f * width);
    }];
}

#pragma mark - 第五页引导
- (void)createFifthGuide
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.pageIndex = 5;
    
    CGFloat width = kMainBoundsWidth / 5 * 4;
    CGFloat scale = kMainBoundsWidth / 1080.f;
    UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFit image:[UIImage imageNamed:@"page5"]];
    [self addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-15 * scale);
        make.centerX.mas_equalTo(88 * scale);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(176.f / 288.f * width);
    }];
}

- (void)nextGuide
{
    if (self.pageIndex == 1) {
        [self createSecondGuide];
    }else if (self.pageIndex == 2) {
        [self createThirdGuide];
    }else if (self.pageIndex == 3) {
        [self createFourthGuide];
    }else if (self.pageIndex == 4) {
        [self createFifthGuide];
    }else{
        [self endGuide];
    }
}

- (void)endGuide
{
    [self removeFromSuperview];
    
    SettingModel * model = [[SettingModel alloc] initWithType:SettingType_AlertTip];
    DDUserDefaultsSet(model.systemKey, @(NO));
    [DDUserDefaults synchronize];
    
    [MBProgressHUD showTextHUDWithText:@"您可以在设置里再次开启操作引导" inView:[UIApplication sharedApplication].keyWindow];
}

@end
