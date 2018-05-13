//
//  MineHeaderView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/10.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "MineHeaderView.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>

@interface MineHeaderView ()

@property (nonatomic, strong) UIImageView * headerImageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * IDLabel;
@property (nonatomic, strong) UIImageView * QRCodeImageView;

@end

@implementation MineHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createMineHeaderView];
    }
    return self;
}

- (void)createMineHeaderView
{
    self.backgroundColor = [UIColor whiteColor];
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.headerImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [self addSubview:self.headerImageView];
    [self.headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(144 * scale);
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(60 * scale);
    }];
    self.headerImageView.layer.cornerRadius = 144 * scale / 2;
    self.headerImageView.layer.masksToBounds = YES;
    [self.headerImageView setImage:[UIImage imageNamed:@"test"]];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(54 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    self.nameLabel.text = @"Your name";
    [self addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(-40 * scale);
        make.left.mas_equalTo(self.headerImageView.mas_right).offset(48 * scale);
        make.height.mas_equalTo(60 * scale);
    }];
    
    self.IDLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.IDLabel.text = @"Dee Dao ID:20180510";
    [self addSubview:self.IDLabel];
    [self.IDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(15 * scale);
        make.left.mas_equalTo(self.headerImageView.mas_right).offset(48 * scale);
        make.height.mas_equalTo(58 * scale);
    }];
    
    self.QRCodeImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFit image:[UIImage imageNamed:@"test"]];
    [self addSubview:self.QRCodeImageView];
    [self.QRCodeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(72 * scale);
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-60 * scale);
    }];
}

@end
