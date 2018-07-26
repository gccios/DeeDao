//
//  LogoCollectionViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/26.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "LogoCollectionViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>

@interface LogoCollectionViewCell ()

@property (nonatomic, strong) UIImageView * logoImageView;

@end

@implementation LogoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createLogoCollectionViewCell];
    }
    return self;
}

- (void)createLogoCollectionViewCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [self.contentView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo(110 * scale);
    }];
    [DDViewFactoryTool cornerRadius:55 * scale withView:self.logoImageView];
}

- (void)confiWithModel:(UserYaoYueModel *)model
{
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
}

@end
