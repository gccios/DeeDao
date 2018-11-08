//
//  SecurityHeaderView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/23.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SecurityHeaderView.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>

@implementation SecurityHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createHeaderView];
    }
    return self;
}

- (void)createHeaderView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    self.backgroundColor = UIColorFromRGB(0xEFEFF4);
    self.frame = CGRectMake(0, 0, kMainBoundsWidth, 710 * scale);
    
    UILabel * nameTip = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:[UIColorFromRGB(0x999999) colorWithAlphaComponent:.87f] alignment:NSTextAlignmentLeft];
    nameTip.text = DDLocalizedString(@"Name");
    [self addSubview:nameTip];
    [nameTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(60 * scale);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
    
    UIView * whiteView1 = [[UIView alloc] initWithFrame:CGRectZero];
    whiteView1.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self addSubview:whiteView1];
    [whiteView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(nameTip.mas_bottom).offset(24 * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(144 * scale);
    }];
    
    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.nameTextField.placeholder = @"请输入圈子名称";
    self.nameTextField.textColor = [UIColorFromRGB(0x333333) colorWithAlphaComponent:.87f];
    [whiteView1 addSubview:self.nameTextField];
    [self.nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(144 * scale);
    }];
    self.nameTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60 * scale, 100 * scale)];
    self.nameTextField.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.nameTextField.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel * DTieTip = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:[UIColorFromRGB(0x999999) colorWithAlphaComponent:.87f] alignment:NSTextAlignmentLeft];
    DTieTip.text = DDLocalizedString(@"D Page Included");
    [self addSubview:DTieTip];
    [DTieTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(whiteView1.mas_bottom).offset(48 * scale);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
    
    self.whiteView2 = [[UIView alloc] initWithFrame:CGRectZero];
    self.whiteView2.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self addSubview:self.whiteView2];
    [self.whiteView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(DTieTip.mas_bottom).offset(24 * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(144 * scale);
    }];
    
    UILabel * DTieLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:[UIColorFromRGB(0x333333) colorWithAlphaComponent:.87f] backgroundColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentLeft];
    DTieLabel.text = @"选择圈内包含D帖";
    [self.whiteView2 addSubview:DTieLabel];
    [DTieLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(144 * scale);
    }];
    
    UIImageView * moreImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"more"]];
    [self.whiteView2 addSubview:moreImageView];
    [moreImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(72 * scale);
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-60 * scale);
    }];
    
    self.numberLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:[UIColorFromRGB(0x999999) colorWithAlphaComponent:.87f] alignment:NSTextAlignmentLeft];
    self.numberLabel.text = DDLocalizedString(@"Members");
    [self addSubview:self.numberLabel];
    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.whiteView2.mas_bottom).offset(48 * scale);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
    
    UIView * whiteView3 = [[UIView alloc] initWithFrame:CGRectZero];
    whiteView3.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self addSubview:whiteView3];
    [whiteView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(60 * scale);
    }];
}

@end
