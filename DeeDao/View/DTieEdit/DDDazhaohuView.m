//
//  DDDazhaohuView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/5.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDDazhaohuView.h"
#import "RDAlertAction.h"
#import "DDViewFactoryTool.h"
#import <IQKeyboardManager.h>
#import <Masonry.h>

@interface DDDazhaohuView ()

@property (nonatomic, strong) UIView * showView;

@property (nonatomic, strong) UIButton * firstButton;
@property (nonatomic, strong) UIImageView * firstImageView;
@property (nonatomic, strong) UIButton * secondButton;
@property (nonatomic, strong) UIImageView * secondImageView;
@property (nonatomic, strong) UIButton * thirdButton;
@property (nonatomic, strong) UIImageView * thirdImageView;

@property (nonatomic, copy) NSString * text;

@end

@implementation DDDazhaohuView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createDazhaohuView];
    }
    return self;
}

- (void)createDazhaohuView
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
    self.showView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth - 240 * scale, 700 * scale)];
    self.showView.backgroundColor = UIColorFromRGB(0xffffff);
    [self addSubview:self.showView];
    self.showView.layer.cornerRadius = 8.f;
    self.showView.layer.masksToBounds = YES;
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth - 240 * scale, 700 * scale);
    [self.showView.layer addSublayer:gradientLayer];
    
    UIView * coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth - 240 * scale, 700 * scale)];
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
    titleLabel.text = @"打招呼时捎个话";
    titleLabel.font = [UIFont boldSystemFontOfSize:48 * scale];
    [self.showView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(50 * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(60 * scale);
    }];
    
    self.firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.showView addSubview:self.firstButton];
    [self.firstButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(60 * scale);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(70 * scale);
    }];
    
    self.firstImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"chooseyes"]];
    [self.firstButton addSubview:self.firstImageView];
    [self.firstImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.centerY.mas_equalTo(0);
        make.width.height.mas_equalTo(60 * scale);
    }];
    
    UILabel * firstLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    firstLabel.text = @"hi~好巧，我也刚好路过这里。";
    [self.firstButton addSubview:firstLabel];
    [firstLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.firstImageView.mas_right).offset(40 * scale);
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-60 * scale);
    }];
    
    self.secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.showView addSubview:self.secondButton];
    [self.secondButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.firstButton.mas_bottom).offset(30 * scale);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(100 * scale);
    }];
    
    self.secondImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"chooseno"]];
    [self.secondButton addSubview:self.secondImageView];
    [self.secondImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.top.mas_equalTo(10 * scale);
        make.width.height.mas_equalTo(60 * scale);
    }];
    
    UILabel * secondLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    secondLabel.numberOfLines = 0;
    secondLabel.text = @"hi~被你写的D帖吸引到了这里，果然和你描述的一样，太棒了！";
    [self.secondButton addSubview:secondLabel];
    [secondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.firstImageView.mas_right).offset(40 * scale);
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-60 * scale);
    }];
    
    self.thirdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.showView addSubview:self.thirdButton];
    [self.thirdButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.secondButton.mas_bottom).offset(40 * scale);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(100 * scale);
    }];
    
    self.thirdImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"chooseno"]];
    [self.thirdButton addSubview:self.thirdImageView];
    [self.thirdImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.centerY.mas_equalTo(0);
        make.width.height.mas_equalTo(60 * scale);
    }];
    
    UILabel * thirdLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    thirdLabel.numberOfLines = 0;
    thirdLabel.text = @"hi~谢谢你的推荐，这里真的很不错。";
    [self.thirdButton addSubview:thirdLabel];
    [thirdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.thirdImageView.mas_right).offset(40 * scale);
        make.top.mas_equalTo(10 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    
    [self.firstButton addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.secondButton addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.thirdButton addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    RDAlertAction * action1 = [[RDAlertAction alloc] initWithTitle:@"取消" handler:^{
        
    } bold:NO];
    
    RDAlertAction * action2 = [[RDAlertAction alloc] initWithTitle:@"确定" handler:^{
        if (self.block) {
            self.block(self.text);
        }
    } bold:NO];
    [self addActions:@[action1, action2]];
}

- (void)buttonDidClicked:(UIButton *)button
{
    if (button == self.firstButton) {
        [self.firstImageView setImage:[UIImage imageNamed:@"chooseyes"]];
        [self.secondImageView setImage:[UIImage imageNamed:@"chooseno"]];
        [self.thirdImageView setImage:[UIImage imageNamed:@"chooseno"]];
        self.text = @"hi~好巧，我也刚好路过这里。";
        
    }else if (button == self.secondButton) {
        [self.firstImageView setImage:[UIImage imageNamed:@"chooseno"]];
        [self.secondImageView setImage:[UIImage imageNamed:@"chooseyes"]];
        [self.thirdImageView setImage:[UIImage imageNamed:@"chooseno"]];
        self.text = @"hi~被你写的D帖吸引到了这里，果然和你描述的一样，太棒了！";
    }else{
        [self.firstImageView setImage:[UIImage imageNamed:@"chooseno"]];
        [self.secondImageView setImage:[UIImage imageNamed:@"chooseno"]];
        [self.thirdImageView setImage:[UIImage imageNamed:@"chooseyes"]];
        self.text = @"hi~谢谢你的推荐，这里真的很不错。";
    }
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    [self.showView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth - 240 * scale, 700 * scale));
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
