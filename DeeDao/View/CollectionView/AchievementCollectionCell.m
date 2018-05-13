//
//  AchievementCollectionCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/13.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "AchievementCollectionCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>

@interface AchievementCollectionCell ()

@property (nonatomic, strong) UIImageView * chengjiuImageView;
@property (nonatomic, strong) UIView * baseView;
@property (nonatomic, strong) UILabel * IDLabel;
@property (nonatomic, strong) UILabel * chengjiuLabel;

@end

@implementation AchievementCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createAchievementCell];
    }
    return self;
}

- (void)createAchievementCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectZero];
    self.baseView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.baseView];
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(25 * scale);
        make.bottom.right.mas_equalTo(-25 * scale);
    }];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.baseView];
    self.baseView.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.baseView.layer.borderWidth = 3 * scale;
    
    self.chengjiuImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"chengjiu"]];
    [self.contentView addSubview:self.chengjiuImageView];
    [self.chengjiuImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15 * scale);
        make.left.mas_equalTo(45 * scale);
        make.width.height.mas_equalTo(200 * scale);
    }];
    
    self.IDLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    self.IDLabel.numberOfLines = 0;
    self.IDLabel.text = @"DeeDao\n身份证明";
    [self.baseView addSubview:self.IDLabel];
    [self.IDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(-180 * scale);
        make.left.mas_equalTo(250 * scale);
        make.right.mas_equalTo(-5 * scale);
    }];
    
    self.chengjiuLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x000000) alignment:NSTextAlignmentLeft];
    self.chengjiuLabel.numberOfLines = 0;
    [self.baseView addSubview:self.chengjiuLabel];
    [self.chengjiuLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(230 * scale);
        make.left.mas_equalTo(45 * scale);
        make.right.mas_equalTo(-45 * scale);
    }];
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:@"恭喜您于\n" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x000000)}];
    
    NSAttributedString * dateString = [[NSAttributedString alloc] initWithString:@"2018-05-13  23:56" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0xDB6283)}];
    [string appendAttributedString:dateString];
    
    NSAttributedString * preString = [[NSMutableAttributedString alloc] initWithString:@"成功登录DeeDao星球成为" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x000000)}];
    [string appendAttributedString:preString];
    
    NSAttributedString * numberString = [[NSAttributedString alloc] initWithString:@"1" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0xDB6283)}];
    [string appendAttributedString:numberString];
    
    NSAttributedString * fixString = [[NSMutableAttributedString alloc] initWithString:@"位原住民" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x000000)}];
    [string appendAttributedString:fixString];
    self.chengjiuLabel.attributedText = string;
}

@end
