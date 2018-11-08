//
//  DaoDiAlertView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/14.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DaoDiAlertView.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import "UserManager.h"
#import <UIImageView+WebCache.h>

@interface DaoDiAlertView ()

@property (nonatomic, strong) UILabel * detailLabel;

@end

@implementation DaoDiAlertView

- (instancetype)init
{
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        [self createDaoDiAlertView];
    }
    return self;
}

- (void)createDaoDiAlertView
{
    self.tag = 1000;
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 846 * scale, 1200 * scale)];
    contentView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.mas_equalTo(846 * scale);
        make.height.mas_equalTo(1200 * scale);
    }];
    [DDViewFactoryTool cornerRadius:42 * scale withView:contentView];
    
    UIImageView * BGImageview = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [BGImageview setImage:[UIImage imageNamed:@"daodiBG"]];
    [contentView addSubview:BGImageview];
    [BGImageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    UIImageView * logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [logoImageView sd_setImageWithURL:[NSURL URLWithString:[UserManager shareManager].user.portraituri]];
    [BGImageview addSubview:logoImageView];
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(216 * scale);
        make.centerX.mas_equalTo(-2 * scale);
        make.width.height.mas_equalTo(270 * scale);
    }];
    [DDViewFactoryTool cornerRadius:135 * scale withView:logoImageView];
    
    UIImageView * iconImageview = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [iconImageview setImage:[UIImage imageNamed:@"daodiIcon"]];
    [BGImageview addSubview:iconImageview];
    [iconImageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.mas_equalTo(logoImageView);
        make.width.height.mas_equalTo(76 * scale);
    }];
    [DDViewFactoryTool cornerRadius:38 * scale withView:iconImageview];
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(72 * scale) textColor:UIColorFromRGB(0x262628) alignment:NSTextAlignmentCenter];
    titleLabel.text = [NSString stringWithFormat:@"恭喜您 %@", [UserManager shareManager].user.nickname];
    [BGImageview addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(logoImageView.mas_bottom).offset(160 * scale);
        make.centerX.mas_equalTo(0);
        make.left.mas_equalTo(40 * scale);
        make.right.mas_equalTo(-40 * scale);
    }];
    
    self.detailLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0x9B9B9B) alignment:NSTextAlignmentCenter];
    self.detailLabel.text = @"您找到了D帖的真实位置";
    [BGImageview addSubview:self.detailLabel];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(10 * scale);
        make.centerX.mas_equalTo(0);
        make.left.mas_equalTo(40 * scale);
        make.right.mas_equalTo(-40 * scale);
    }];
    
    UIButton * OKButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"好的，打开看看"];
    [contentView addSubview:OKButton];
    [OKButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.detailLabel.mas_bottom).offset(80 * scale);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(600 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    [DDViewFactoryTool cornerRadius:60 * scale withView:OKButton];
    [OKButton addTarget:self action:@selector(OKButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, 600 * scale, 120 * scale);
    [OKButton.layer insertSublayer:gradientLayer atIndex:0];
    
    UIButton * closeButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:DDLocalizedString(@"Off")];
    [contentView addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(OKButton.mas_bottom).offset(40 * scale);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(200 * scale);
        make.height.mas_equalTo(80 * scale);
    }];
    [closeButton addTarget:self action:@selector(closeButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)OKButtonDidClicked
{
    if (self.handleButtonClicked) {
        self.handleButtonClicked();
    }
    [self removeFromSuperview];
}

- (void)closeButtonDidClicked
{
    [self removeFromSuperview];
}

- (void)show
{
    if ([[UIApplication sharedApplication].keyWindow viewWithTag:1000]) {
        
    }else{
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
}

- (void)setIsDaoDi:(BOOL)isDaoDi
{
    _isDaoDi = isDaoDi;
    if (isDaoDi) {
        self.detailLabel.text = @"恭喜你获得地到体验官成就";
    }
}

@end
