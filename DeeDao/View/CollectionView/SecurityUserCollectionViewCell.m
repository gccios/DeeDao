//
//  SecurityUserCollectionViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/23.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SecurityUserCollectionViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>

@interface SecurityUserCollectionViewCell ()

@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * nameLabel;

@property (nonatomic, strong) UIButton * cancleButton;

@property (nonatomic, strong) UIImageView * addImageView;;

@end

@implementation SecurityUserCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createSecurityUserCollectionViewCell];
    }
    return self;
}

- (void)configWithModel:(UserModel *)model
{
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
    self.nameLabel.text = model.nickname;
    
    self.cancleButton.hidden = NO;
    self.logoImageView.hidden = NO;
    self.nameLabel.hidden = NO;
    self.addImageView.hidden = YES;
}

- (void)configAddCell
{
    self.cancleButton.hidden = YES;
    self.logoImageView.hidden = YES;
    self.nameLabel.hidden = YES;
    self.addImageView.hidden = NO;
}

- (void)createSecurityUserCollectionViewCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"test"]];
    [self.contentView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(24 * scale);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(120 * scale);
    }];
    [DDViewFactoryTool cornerRadius:60 * scale withView:self.logoImageView];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:[UIColorFromRGB(0x000000) colorWithAlphaComponent:.87f] alignment:NSTextAlignmentCenter];
    self.nameLabel.text = @"Just丶DeeDao";
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30*scale);
        make.top.mas_equalTo(self.logoImageView.mas_bottom).offset(15 * scale);
        make.right.mas_equalTo(-30*scale);
        make.height.mas_equalTo(55 * scale);
    }];
    
    self.cancleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(40 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [self.cancleButton setImage:[UIImage imageNamed:@"jianqu"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.cancleButton];
    [self.cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10 * scale);
        make.right.mas_equalTo(self.logoImageView).offset(15 * scale);
        make.width.height.mas_equalTo(60 * scale);
    }];
    [self.cancleButton addTarget:self action:@selector(cancleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.addImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [self.addImageView setImage:[UIImage imageNamed:@"jiahaoyou"]];
    [self.contentView addSubview:self.addImageView];
    [self.addImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.logoImageView);
        make.width.height.mas_equalTo(self.logoImageView);
    }];
    [DDViewFactoryTool cornerRadius:60 * scale withView:self.addImageView];
    self.addImageView.hidden = YES;
}

- (void)cancleButtonDidClicked
{
    if (self.cancleButtonHandle) {
        self.cancleButtonHandle();
    }
}

@end
