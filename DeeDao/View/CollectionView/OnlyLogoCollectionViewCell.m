//
//  OnlyLogoCollectionViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "OnlyLogoCollectionViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>

@interface OnlyLogoCollectionViewCell ()

@property (nonatomic, strong) UserModel * model;
@property (nonatomic, strong) UIImageView * logoImageView;

@end

@implementation OnlyLogoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createLogoCell];
    }
    return self;
}

- (void)configWithUserModel:(UserModel *)model
{
    self.model = model;
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
}

- (void)createLogoCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    
    [self.contentView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo(96 * scale);
    }];
    [DDViewFactoryTool cornerRadius:48 * scale withView:self.logoImageView];
}

@end
