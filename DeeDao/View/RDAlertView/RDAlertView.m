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

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

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
    
    self.showView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
    self.showView.backgroundColor = UIColorFromRGB(0xf6f2ed);
    [self addSubview:self.showView];
    self.showView.layer.cornerRadius = 8.f;
    self.showView.layer.masksToBounds = YES;
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, self.showView.frame.size.width - 20, 20)];
    titleLabel.textColor = UIColorFromRGB(0x222222);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = title;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.showView addSubview:titleLabel];
    
    UILabel * messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, self.showView.frame.size.width - 20, 110)];
    messageLabel.textColor = UIColorFromRGB(0x333333);
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.text = message;
    messageLabel.numberOfLines = 0;
    messageLabel.font = [UIFont systemFontOfSize:17];
    [self.showView addSubview:messageLabel];
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
    
    [self.showView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(300, 200));
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
    if (actions.count == 1) {
        RDAlertAction * action = [actions firstObject];
        [action addTarget:self action:@selector(actionDidBeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.showView addSubview:action];
        [action mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(160, 36));
            make.bottom.mas_equalTo(-15);
            make.centerX.mas_equalTo(0);
        }];
        action.layer.cornerRadius = 18;
        action.layer.masksToBounds = YES;
    }else if (actions.count == 2) {
        RDAlertAction * leftAction = [actions firstObject];
        [leftAction addTarget:self action:@selector(actionDidBeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.showView addSubview:leftAction];
        CGFloat width = (self.showView.frame.size.width - 40 - 15) / 2;
        [leftAction mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.bottom.mas_equalTo(-15);
            make.height.mas_equalTo(36);
            make.width.mas_equalTo(width);
        }];
        leftAction.layer.cornerRadius = 18;
        leftAction.layer.masksToBounds = YES;
        
        RDAlertAction * rightAction = [actions lastObject];
        [rightAction addTarget:self action:@selector(actionDidBeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.showView addSubview:rightAction];
        [rightAction mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-20);
            make.bottom.mas_equalTo(-15);
            make.height.mas_equalTo(36);
            make.width.mas_equalTo(width);
        }];
        rightAction.layer.cornerRadius = 18;
        rightAction.layer.masksToBounds = YES;
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
