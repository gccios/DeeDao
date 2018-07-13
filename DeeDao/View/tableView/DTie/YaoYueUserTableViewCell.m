//
//  YaoYueUserTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/13.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "YaoYueUserTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import "UIView+LayerCurve.h"
#import "UserInfoViewController.h"
#import "DDTool.h"
#import <UIImageView+WebCache.h>

@interface YaoYueUserTableViewCell ()

@property (nonatomic, strong) UserYaoYueModel * model;
@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * nameLabel;
//@property (nonatomic, strong) UILabel * timeLabel;

@property (nonatomic, strong) UIButton * yaoyueButton;
@property (nonatomic, strong) UIButton * yiyueButton;

@end

@implementation YaoYueUserTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createYaoYueUserCell];
    }
    return self;
}

- (void)createYaoYueUserCell
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIImageView * headerBGView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"headerBG"]];
    [self.contentView addSubview:headerBGView];
    [headerBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(38 * scale);
        make.width.height.mas_equalTo(116 * scale);
    }];
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [self.contentView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(48 * scale);
        make.width.height.mas_equalTo(96 * scale);
    }];
    [DDViewFactoryTool cornerRadius:48 * scale withView:self.logoImageView];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoImageViewDidClicked)];
    self.logoImageView.userInteractionEnabled = YES;
    [self.logoImageView addGestureRecognizer:tap];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0x00000) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(70 * scale);
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(48 * scale);
        make.height.mas_equalTo(55 * scale);
        make.right.mas_equalTo(-200 * scale);
    }];
    
//    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:[UIColorFromRGB(0x999999) colorWithAlphaComponent:.54f] alignment:NSTextAlignmentLeft];
//    [self.contentView addSubview:self.timeLabel];
//    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(0 * scale);
//        make.left.mas_equalTo(self.logoImageView.mas_right).offset(48 * scale);
//        make.height.mas_equalTo(45 * scale);
//        make.right.mas_equalTo(-50 * scale);
//    }];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 840 * scale, 2 * scale)];
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(2 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.bottom.mas_equalTo(0 * scale);
    }];
    [lineView layerDotteLinePoints:@[[NSValue valueWithCGPoint:CGPointMake(0, 0)], [NSValue valueWithCGPoint:CGPointMake(960 * scale, 0)]] Color:UIColorFromRGB(0x999999) Width:2 * scale SolidLength:4 * scale DotteLength:8 * scale];
    
    self.yaoyueButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0XFFFFFF) title:@"约ta"];
    [self.contentView addSubview:self.yaoyueButton];
    [self.yaoyueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(132 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    [DDViewFactoryTool cornerRadius:12 * scale withView:self.yaoyueButton];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, 132 * scale, 72 * scale);
    [self.yaoyueButton.layer insertSublayer:gradientLayer atIndex:0];
    [self.yaoyueButton addTarget:self action:@selector(yaoyueButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.yiyueButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"已约"];
    [self.contentView addSubview:self.yiyueButton];
    [self.yiyueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(132 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    [DDViewFactoryTool cornerRadius:12 * scale withView:self.yiyueButton];
    self.yiyueButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.yiyueButton.layer.borderWidth = 3 * scale;
    self.yiyueButton.hidden = YES;
    [self.yiyueButton addTarget:self action:@selector(yiyueButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)yaoyueButtonDidClicked
{
    if (self.yaoyueButtonHandle) {
        self.yaoyueButtonHandle(self.model);
    }
}

- (void)yiyueButtonDidClicked
{
    if (self.yiyueButtonHandle) {
        self.yiyueButtonHandle(self.model);
    }
}

- (void)logoImageViewDidClicked
{
    UITabBarController * tab = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)tab.selectedViewController;
    
    UserInfoViewController * info = [[UserInfoViewController alloc] initWithUserId:self.model.cid];
    [na pushViewController:info animated:YES];
}

- (void)configWithModel:(UserYaoYueModel *)model
{
    self.model = model;
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
    self.nameLabel.text = model.nickname;
//    self.timeLabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:model.timestamp];
}

- (void)configSelectStatus:(BOOL)status
{
    if (status) {
        self.yiyueButton.hidden = NO;
        self.yaoyueButton.hidden = YES;
    }else{
        self.yiyueButton.hidden = YES;
        self.yaoyueButton.hidden = NO;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
