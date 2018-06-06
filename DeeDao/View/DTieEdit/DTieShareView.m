//
//  DTieShareView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/5.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieShareView.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>

@implementation DTieShareView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createDTieShareView];
    }
    return self;
}

- (void)createDTieShareView
{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFromSuperview)];
    [self addGestureRecognizer:tap];
    
    NSArray * imageNames = @[@"sharepengyouquan", @"shareweixin", @"shareFriend", @"sharebozhu"];
    NSArray * titles = @[@"微信朋友圈", @"微信好友或群", @"地到好友", @"地到博主"];
    CGFloat width = kMainBoundsWidth / imageNames.count;
    CGFloat height = width;
    if (KIsiPhoneX) {
        height += 38.f;
    }
    CGFloat scale = kMainBoundsWidth / 1080.f;
    for (NSInteger i = 0; i < imageNames.count; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor whiteColor];
        button.tag = 10 + i;
        [button addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(i * width);
            make.height.mas_equalTo(height);
            make.bottom.mas_equalTo(0);
            make.width.mas_equalTo(width);
        }];
        
        UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
        [button addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(50 * scale);
            make.width.height.mas_equalTo(96 * scale);
        }];
        
        UILabel * label = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentCenter];
        label.text = [titles objectAtIndex:i];
        [button addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(45 * scale);
            make.top.mas_equalTo(imageView.mas_bottom).offset(20 * scale);
        }];
    }
}

- (void)buttonDidClicked:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(DTieShareDidSelectIndex:)]) {
        [self.delegate DTieShareDidSelectIndex:button.tag - 10];
    }
    [self removeFromSuperview];
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

@end
