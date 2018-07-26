//
//  MapFriendCollectionViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "MapFriendCollectionViewCell.h"
#import "DDViewFactoryTool.h"
#import <UIImageView+WebCache.h>
#import <Masonry.h>

@interface MapFriendCollectionViewCell ()

@property (nonatomic, strong) UserModel * model;
@property (nonatomic, strong) UIView * baseView;

@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UIImageView * chooseImageView;

@end

@implementation MapFriendCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createMapFriendCollectionViewCell];
    }
    return self;
}

- (void)configWithModel:(UserModel *)model
{
    self.model = model;
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
    self.nameLabel.text = model.nickname;
}

- (void)configSelectStatus:(BOOL)status
{
    if (status) {
        [self.chooseImageView setImage:[UIImage imageNamed:@"chooseyes"]];
    }else{
        [self.chooseImageView setImage:[UIImage imageNamed:@"chooseno"]];
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.baseView.backgroundColor = [UIColorFromRGB(0xdb6283) colorWithAlphaComponent:.3f];
    }else{
        self.baseView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    }
}

- (void)createMapFriendCollectionViewCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.baseView = [[UIView alloc] init];
    [self.contentView addSubview:self.baseView];
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(20 * scale);
        make.bottom.right.mas_equalTo(-20 * scale);
    }];
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [self.baseView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(-50 * scale);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(110 * scale);
    }];
    [DDViewFactoryTool cornerRadius:55 * scale withView:self.logoImageView];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentCenter];
    [self.baseView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.logoImageView.mas_bottom).offset(20 * scale);
        make.left.right.mas_equalTo(0);
    }];
    
    self.chooseImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"chooseno"]];
    [self.baseView addSubview:self.chooseImageView];
    [self.chooseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0 * scale);
        make.bottom.mas_equalTo(-10 * scale);
        make.width.height.mas_equalTo(60 * scale);
    }];
}

@end
