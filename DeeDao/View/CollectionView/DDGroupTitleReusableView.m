//
//  DDGroupTitleReusableView.m
//  DeeDao
//
//  Created by 郭春城 on 2019/1/4.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DDGroupTitleReusableView.h"
#import <Masonry.h>
#import "DDViewFactoryTool.h"

@interface DDGroupTitleReusableView ()

@property (nonatomic, strong) UILabel * titleLabel;

@end

@implementation DDGroupTitleReusableView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createGroupTitleView];
    }
    return self;
}

- (void)configWithTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)createGroupTitleView
{
    CGFloat scale = kMainBoundsWidth / 360.f;
    
    self.titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(12 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentCenter];
    self.titleLabel.alpha = .5f;
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(20 * scale);
    }];
}

@end
