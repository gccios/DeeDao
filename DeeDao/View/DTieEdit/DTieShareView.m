//
//  DTieShareView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/5.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieShareView.h"
#import "DDViewFactoryTool.h"
#import "UserManager.h"
#import <WXApi.h>
#import <Masonry.h>

@implementation DTieShareView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createDTieShareView];
    }
    return self;
}

- (instancetype)initCreatePostWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createDTieShareViewWithCreatePost];
    }
    return self;
}

- (void)createDTieShareViewWithCreatePost
{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFromSuperview)];
    [self addGestureRecognizer:tap];
    
    NSArray * imageNames;
    NSArray * titles;
    NSInteger startTag;
    
    BOOL isInstallWX = [WXApi isWXAppInstalled];
    BOOL isBozhu = NO;
    if ([UserManager shareManager].user.bloggerFlg == 1) {
        isBozhu = YES;
    }
    
    if (isBozhu && isInstallWX) {
        imageNames = @[@"sharepengyouquan", @"shareweixin", @"saveToPhone", @"shareKouling", @"sharebozhu"];
        titles = @[DDLocalizedString(@"Wechat Groups"), DDLocalizedString(@"Wechat Connections"), DDLocalizedString(@"SinglePost"), @"帖子口令", @"博主码"];
        startTag = 10;
    }else if (isBozhu && !isInstallWX) {
        imageNames = @[@"shareKouling", @"sharebozhu"];
        titles = @[@"帖子口令", @"博主码"];
        startTag = 13;
    }else if (!isBozhu && isInstallWX) {
        imageNames = @[@"sharepengyouquan", @"shareweixin", @"saveToPhone", @"shareKouling"];
        titles = @[DDLocalizedString(@"Wechat Groups"), DDLocalizedString(@"Wechat Connections"), DDLocalizedString(@"SinglePost"), @"帖子口令"];
        startTag = 10;
    }else{
        imageNames = @[@"shareKouling"];
        titles = @[@"帖子口令"];
        startTag = 13;
    }
    
    CGFloat width = kMainBoundsWidth / imageNames.count;
    CGFloat height = kMainBoundsWidth / 4.f;
    if (KIsiPhoneX) {
        height += 38.f;
    }
    CGFloat scale = kMainBoundsWidth / 1080.f;
    for (NSInteger i = 0; i < imageNames.count; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor whiteColor];
        button.tag = startTag + i;
        
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

- (void)createDTieShareView
{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFromSuperview)];
    [self addGestureRecognizer:tap];
    
    NSArray * imageNames;
    NSArray * titles;
    NSInteger startTag;
    
    BOOL isInstallWX = [WXApi isWXAppInstalled];
    BOOL isBozhu = NO;;
    if ([UserManager shareManager].user.bloggerFlg == 1) {
        isBozhu = YES;
    }
    
    if (isBozhu && isInstallWX) {
        imageNames = @[@"sharepengyouquan", @"shareweixin", @"saveToPhone", @"shareKouling", @"sharebozhu"];
        titles = @[DDLocalizedString(@"Wechat Groups"), DDLocalizedString(@"Wechat Connections"), DDLocalizedString(@"SinglePost"), @"帖子口令", @"博主码"];
        startTag = 10;
    }else if (isBozhu && !isInstallWX) {
        imageNames = @[@"shareKouling", @"sharebozhu"];
        titles = @[@"帖子口令", @"博主码"];
        startTag = 13;
    }else if (!isBozhu && isInstallWX) {
        imageNames = @[@"sharepengyouquan", @"shareweixin", @"saveToPhone", @"shareKouling"];
        titles = @[DDLocalizedString(@"Wechat Groups"), DDLocalizedString(@"Wechat Connections"), DDLocalizedString(@"SinglePost"), @"帖子口令"];
        startTag = 10;
    }else{
        imageNames = @[@"shareKouling"];
        titles = @[@"帖子口令"];
        startTag = 13;
    }
    
    CGFloat width = kMainBoundsWidth / imageNames.count;
    CGFloat height = kMainBoundsWidth / 4.f;
    if (KIsiPhoneX) {
        height += 38.f;
    }
    CGFloat scale = kMainBoundsWidth / 1080.f;
    for (NSInteger i = 0; i < imageNames.count; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor whiteColor];
        button.tag = startTag + i;
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
