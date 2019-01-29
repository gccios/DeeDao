//
//  DDGroupCollectionViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2019/1/3.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DDGroupCollectionViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import "ChooseTypeButton.h"
#import <UIImageView+WebCache.h>

@interface DDGroupCollectionViewCell ()

@property (nonatomic, strong) UIImageView * chooseImageView;
@property (nonatomic, strong) ChooseTypeButton * groupButton;
@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * nameLabel;

@property (nonatomic, strong) UIView * tagView;

@end

@implementation DDGroupCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createGroupCollectionCell];
    }
    return self;
}

- (void)hiddenChooseImageView
{
    self.chooseImageView.hidden = YES;
}

- (void)showChooseImageView
{
    self.chooseImageView.hidden = NO;
}

- (void)configWithModel:(DDGroupModel *)model
{
    if (model.newFlag == 0) {
        self.tagView.hidden = YES;
    }else{
        self.tagView.hidden = NO;
    }
    self.nameLabel.text = model.groupName;
    if (model.isSystem) {
        if (model.cid == -2 || model.cid == -3) {
            [self.logoImageView setImage:[UIImage imageNamed:model.groupPic]];
        }else{
            [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.groupPic]];
        }
    }else{
        if (isEmptyString(model.groupPic)) {
            [self.logoImageView setImage:[UIImage imageNamed:@"groupDefault"]];
        }else{
            [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.groupPic]];
        }
    }
}

- (void)createGroupCollectionCell
{
    CGFloat scale = kMainBoundsWidth / 360.f;
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.groupButton = [ChooseTypeButton buttonWithType:UIButtonTypeCustom];
    [self.groupButton setBackgroundImage:[UIImage imageNamed:@"PDButton"] forState:UIControlStateNormal];
    [self.groupButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 25 * scale, 0)];
    self.groupButton.frame = CGRectMake(0, 0, 400 * scale, 400 * scale);
    [self.contentView addSubview:self.groupButton];
    [self.groupButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(30 * scale);
        make.width.height.mas_equalTo(114 * scale);
    }];
    [self.groupButton addTarget:self action:@selector(buttonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.chooseImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFit image:[UIImage imageNamed:@"currentPD"]];
    [self.contentView addSubview:self.chooseImageView];
    [self.chooseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.groupButton.mas_top);
    }];
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@""]];
    self.logoImageView.clipsToBounds = YES;
    [self.groupButton addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(24 * scale);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(56 * scale);
    }];
    [DDViewFactoryTool cornerRadius:28 * scale withView:self.logoImageView];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(16 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentCenter];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.centerX.mas_equalTo(5 * scale);
        make.height.mas_equalTo(20 * scale);
    }];
    
    self.tagView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tagView.backgroundColor = UIColorFromRGB(0xFC6E60);
    [DDViewFactoryTool cornerRadius:5.5 withView:self.tagView];
    self.tagView.layer.borderColor = UIColorFromRGB(0xFFFFFF).CGColor;
    self.tagView.layer.borderWidth = .5f;
    [self.contentView addSubview:self.tagView];
    [self.tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_right).offset(3);
        make.centerY.mas_equalTo(self.nameLabel);
        make.width.height.mas_equalTo(11);
    }];
}

- (void)buttonDidClicked
{
    if (self.groupDidChooseHandle) {
        self.groupDidChooseHandle();
    }
}

@end
