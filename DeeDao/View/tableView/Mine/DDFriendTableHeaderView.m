//
//  DDFriendTableHeaderView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/14.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDFriendTableHeaderView.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>

@interface DDFriendTableHeaderView ()

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIView * preView;
@property (nonatomic, strong) UILabel * preLabel;

@end

@implementation DDFriendTableHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self createFriendHeader];
    }
    return self;
}

- (void)createFriendHeader
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0x3F3F3F) alignment:NSTextAlignmentLeft];
    self.titleLabel.text = @"好友列表";
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.top.mas_equalTo(60 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    self.preView = [[UIView alloc] initWithFrame:CGRectZero];
    self.preView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self addSubview:self.preView];
    [self.preView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(80 * scale);
        make.bottom.mas_equalTo(0);
    }];
    
    self.preLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(54 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    self.preLabel.text = @"J";
    [self.preView addSubview:self.preLabel];
    [self.preLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(58 * scale);
        make.bottom.mas_equalTo(0);
    }];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = [UIColorFromRGB(0x00000) colorWithAlphaComponent:.12f];
    [self.preView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.bottom.mas_equalTo(-29 * scale);
        make.height.mas_equalTo(3 * scale);
        make.right.mas_equalTo(self.preLabel.mas_left).offset(-20 * scale);
    }];
}

- (void)configWithPre:(NSString *)pre
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.titleLabel.hidden = YES;
    self.preView.hidden = NO;
    self.preLabel.text = pre;
    
    self.frame = CGRectMake(0, 0, kMainBoundsWidth, 80 * scale);
}

-(void)configWithPre:(NSString *)pre title:(NSString *)title
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.titleLabel.hidden = NO;
    self.preView.hidden = NO;
    
    self.frame = CGRectMake(0, 0, kMainBoundsWidth, 170 * scale);
}

- (void)configWithTitle:(NSString *)title
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.titleLabel.hidden = NO;
    self.preView.hidden = YES;
    
    self.frame = CGRectMake(0, 0, kMainBoundsWidth, 90 * scale);
}

@end
