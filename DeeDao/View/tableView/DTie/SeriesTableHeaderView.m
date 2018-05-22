//
//  SeriesTableHeaderView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SeriesTableHeaderView.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>

@interface SeriesTableHeaderView ()

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIButton * addButton;

@end

@implementation SeriesTableHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self createSeriesView];
    }
    return self;
}

- (void)createSeriesView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0xCCCCCC);
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.top.mas_equalTo(77 * scale);
        make.height.mas_equalTo(2 * scale);
    }];
    
    self.titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xCCCCCC) alignment:NSTextAlignmentCenter];
    self.titleLabel.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(220 * scale);
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(60 * scale);
        make.height.mas_equalTo(40 * scale);
    }];
    
    self.addButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"新增系列"];
    [self.addButton setImage:[UIImage imageNamed:@"DTieAdd"] forState:UIControlStateNormal];
    [self addSubview:self.addButton];
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(144 * scale);
        make.bottom.mas_equalTo(-40 * scale);
    }];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.addButton];
    self.addButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.addButton.layer.borderWidth = 3 * scale;
    [self.addButton addTarget:self action:@selector(addButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addButtonDidClicked
{
    if (self.addSeriesHandle) {
        self.addSeriesHandle();
    }
}

- (void)configWithSetTop:(BOOL)isTop
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    if (isTop) {
        self.titleLabel.text = @"置顶系列";
        self.addButton.hidden = YES;
        self.frame = CGRectMake(0, 0, kMainBoundsWidth, 120 * scale);
    }else{
        self.titleLabel.text = @"系列列表";
        self.addButton.hidden = NO;
        self.frame = CGRectMake(0, 0, kMainBoundsWidth, 340 * scale);
    }
}

@end
