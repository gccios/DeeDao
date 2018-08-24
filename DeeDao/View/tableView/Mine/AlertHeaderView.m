//
//  AlertHeaderView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "AlertHeaderView.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>

@interface AlertHeaderView ()

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIImageView * rightImageView;

@end

@implementation AlertHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self createAlertHeaderView];
    }
    return self;
}

- (void)createAlertHeaderView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.contentView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    self.titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(72 * scale);
    }];
    
    self.rightImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"open"]];
    [self.contentView addSubview:self.rightImageView];
    [self.rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-60 * scale);
        make.width.height.mas_equalTo(72 * scale);
    }];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(3 * scale);
    }];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClicked)];
    [self addGestureRecognizer:tap];
}

- (void)didClicked
{
    if (self.clickedHandle) {
        self.clickedHandle();
    }
}

- (void)configWithTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)configWithOpenStaus:(BOOL)isOpen
{
    if (isOpen) {
        [self.rightImageView setImage:[UIImage imageNamed:@"upclose"]];
    }else{
        [self.rightImageView setImage:[UIImage imageNamed:@"open"]];
    }
}

@end
