//
//  NewSeriesCollectionViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/7.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "NewSeriesCollectionViewCell.h"
#import <Masonry.h>
#import "DDViewFactoryTool.h"

@interface NewSeriesCollectionViewCell ()

@property (nonatomic, strong) UIImageView * BGImageView;
@property (nonatomic, strong) UILabel * titleLabel;

@end

@implementation NewSeriesCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createSeriesCollectionViewCell];
    }
    return self;
}

- (void)configWithModel:(SeriesModel *)model
{
    self.titleLabel.text = model.seriesTitle;
}

- (void)createSeriesCollectionViewCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.BGImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"xilieBG"]];
    [self.contentView addSubview:self.BGImageView];
    [self.BGImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(504 * scale);
        make.height.mas_equalTo(348 * scale);
    }];
    self.BGImageView.clipsToBounds = YES;
    
    self.titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(38 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentLeft];
    self.titleLabel.numberOfLines = 2.f;
    self.titleLabel.text = @"这是测试这是测试这是测试这是测试这是测试这是测试这是测试这是测试";
    [self.BGImageView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(104 * scale);
        make.bottom.mas_equalTo(-40 * scale);
        make.left.mas_equalTo(40 * scale);
        make.right.mas_equalTo(-24 * scale);
    }];
    
    UIView * coverView = [[UIView alloc] initWithFrame:CGRectZero];
    coverView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.contentView addSubview:coverView];
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(70 * scale);
    }];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor, (__bridge id)[UIColorFromRGB(0x9B9B9B) colorWithAlphaComponent:.15f].CGColor];
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth / 2 + 1, 15 * scale);
    [coverView.layer addSublayer:gradientLayer];
}

@end
