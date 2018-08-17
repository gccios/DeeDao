//
//  ChooseCategroyCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/16.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "ChooseCategroyCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>

@interface ChooseCategroyCell ()

@property (nonatomic, strong) UILabel * titleLabel;

@end

@implementation ChooseCategroyCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createChooseCell];
    }
    return self;
}

- (void)createChooseCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xdb6283) alignment:NSTextAlignmentCenter];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:60 * scale withView:self.titleLabel];
    self.titleLabel.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.titleLabel.layer.borderWidth = 3 * scale;
}

- (void)configTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

@end
