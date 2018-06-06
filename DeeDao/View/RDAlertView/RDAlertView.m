//
//  RDAlertView.m
//  Test - 2.1
//
//  Created by 郭春城 on 17/3/7.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDAlertView.h"
#import <IQKeyboardManager.h>
#import <Masonry.h>

@interface RDAlertView ()

@property (nonatomic, strong) UIView * showView;

@end

@implementation RDAlertView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message
{
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        [self createAlertWithTitle:title message:message];
        self.tag = 333;
    }
    return self;
}

- (void)createAlertWithTitle:(NSString *)title message:(NSString *)message
{
//    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
//    effectView.frame = CGRectMake(0, 0, self.frame.size.width * 0.5, self.frame.size.height);
//    [self addSubview:effectView];
//    [effectView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(0);
//    }];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.7f];
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    self.showView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth - 240 * scale, 687 * scale)];
    self.showView.backgroundColor = UIColorFromRGB(0xffffff);
    [self addSubview:self.showView];
    self.showView.layer.cornerRadius = 8.f;
    self.showView.layer.masksToBounds = YES;
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth - 240 * scale, 687 * scale);
    [self.showView.layer addSublayer:gradientLayer];
    
    UIView * coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth - 240 * scale, 687 * scale)];
    coverView.backgroundColor = UIColorFromRGB(0xffffff);
    [self.showView addSubview:coverView];
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(6 * scale);
        make.bottom.right.mas_equalTo(-6 * scale);
    }];
    coverView.layer.cornerRadius = 8.f;
    coverView.layer.masksToBounds = YES;
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, self.showView.frame.size.width - 20, 20)];
    titleLabel.textColor = UIColorFromRGB(0x666666);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = title;
    titleLabel.font = [UIFont boldSystemFontOfSize:48 * scale];
    [self.showView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(50 * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(60 * scale);
    }];
    
    UILabel * messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, self.showView.frame.size.width - 20, 110)];
    messageLabel.textColor = UIColorFromRGB(0x666666);
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.text = message;
    messageLabel.numberOfLines = 0;
    messageLabel.font = [UIFont systemFontOfSize:42 * scale];
    [self.showView addSubview:messageLabel];
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(40 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.bottom.mas_equalTo(-184 * scale);
    }];
}

- (void)show
{
    UIView * view = [[UIApplication sharedApplication].keyWindow viewWithTag:333];
    if (view) {
        [view removeFromSuperview];
    }
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    [self.showView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 240 * scale, 687 * scale));
        if ([IQKeyboardManager sharedManager].isKeyboardShowing) {
            make.centerX.mas_equalTo(0);
            make.centerY.mas_equalTo(-self.frame.size.width / 4);
        }else{
            make.center.mas_equalTo(0);
        }
    }];
}

- (void)addActions:(NSArray<RDAlertAction *> *)actions
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    if (actions.count == 1) {
        RDAlertAction * action = [actions firstObject];
        [action addTarget:self action:@selector(actionDidBeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.showView addSubview:action];
        [action mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.height.mas_equalTo(144 * scale);
            make.width.mas_equalTo(self.showView.bounds.size.width);
        }];
        
        UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
        lineView.backgroundColor = UIColorFromRGB(0xCCCCCC);
        [self.showView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(6 * scale);
            make.right.mas_equalTo(-6 * scale);
            make.height.mas_equalTo(3 * scale);
            make.top.mas_equalTo(action.mas_top);
        }];
        
    }else if (actions.count == 2) {
        RDAlertAction * leftAction = [actions firstObject];
        [leftAction addTarget:self action:@selector(actionDidBeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.showView addSubview:leftAction];
        CGFloat width = self.showView.frame.size.width / 2;
        [leftAction mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.height.mas_equalTo(144 * scale);
            make.width.mas_equalTo(width);
        }];
        
        RDAlertAction * rightAction = [actions lastObject];
        [rightAction addTarget:self action:@selector(actionDidBeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.showView addSubview:rightAction];
        [rightAction mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.height.mas_equalTo(144 * scale);
            make.width.mas_equalTo(width);
        }];
        
        UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
        lineView.backgroundColor = UIColorFromRGB(0xCCCCCC);
        [self.showView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(6 * scale);
            make.right.mas_equalTo(-6 * scale);
            make.height.mas_equalTo(3 * scale);
            make.top.mas_equalTo(leftAction.mas_top);
        }];
        
        UIView * lineView2 = [[UIView alloc] initWithFrame:CGRectZero];
        lineView2.backgroundColor = UIColorFromRGB(0xCCCCCC);
        [self.showView addSubview:lineView2];
        [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-6 * scale);
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(3 * scale);
            make.height.mas_equalTo(144 * scale);
        }];
    }
}

- (void)actionDidBeClicked:(RDAlertAction *)action
{
    if (action.block) {
        action.block();
    }
    [self removeFromSuperview];
}

@end
