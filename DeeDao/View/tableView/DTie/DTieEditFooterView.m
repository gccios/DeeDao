//
//  DTieEditFooterView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/12.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieEditFooterView.h"
#import <Masonry.h>
#import "DDViewFactoryTool.h"
#import "DDLocationManager.h"
#import "DDTool.h"

@implementation DTieEditFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createDTieEditFooterView];
    }
    return self;
}

- (void)createDTieEditFooterView
{
    self.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.locationButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0x666666) title:@""];
    [self addSubview:self.locationButton];
    [self.locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(80 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(85 * scale);
    }];
    
    UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"location"]];
    [self addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(25 * scale);
        make.left.mas_equalTo(60 * scale);
        make.width.height.mas_equalTo(72 * scale);
    }];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.timeLabel.text = [DDTool getCurrentTimeWithFormat:@"yyyy年MM月dd日 HH:mm"];
    [self addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15 * scale);
        make.left.mas_equalTo(imageView.mas_right).offset(12 * scale);
        make.height.mas_equalTo(65 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    
    self.locationLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.locationLabel.text = [DDLocationManager shareManager].result.address;
    [self.locationButton addSubview:self.locationLabel];
    [self.locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(0);
        make.left.mas_equalTo(self.timeLabel);
        make.height.mas_equalTo(self.timeLabel);
        make.right.mas_equalTo(self.timeLabel);
    }];
    
    self.AddButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"添加模块"];
    [self addSubview:self.AddButton];
    [self.AddButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.top.mas_equalTo(self.locationLabel.mas_bottom).offset(45 * scale);
        make.height.mas_equalTo(144 * scale);
    }];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.AddButton];
    self.AddButton.layer.borderWidth = 3 * scale;
    self.AddButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
}

@end
