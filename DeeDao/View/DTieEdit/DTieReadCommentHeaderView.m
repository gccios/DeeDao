//
//  DTieReadCommentHeaderView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieReadCommentHeaderView.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>

@implementation DTieReadCommentHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self createCommentHeaderView];
    }
    return self;
}

- (void)createCommentHeaderView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(2 * scale);
    }];
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentCenter];
    titleLabel.text = @"评论和留言";
    titleLabel.backgroundColor = UIColorFromRGB(0XFFFFFF);
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.mas_equalTo(300 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
}

@end