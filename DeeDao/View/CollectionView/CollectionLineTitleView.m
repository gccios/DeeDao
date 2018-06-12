//
//  CollectionLineTitleView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/7.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "CollectionLineTitleView.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>

@interface CollectionLineTitleView ()

@property (nonatomic, strong) UILabel * titleLabel;

@end

@implementation CollectionLineTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createLineTtileView];
    }
    return self;
}

- (void)createLineTtileView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    self.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(2 * scale);
    }];
    
    self.titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xCCCCCC) alignment:NSTextAlignmentCenter];
    self.titleLabel.backgroundColor = UIColorFromRGB(0XFFFFFF);
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.mas_equalTo(300 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
}

- (void)confiTitle:(NSString *)title
{
    self.titleLabel.text = title;
    
    if (isEmptyString(title)) {
        self.alpha = 0;
    }else{
        self.alpha = 1;
    }
}

@end
