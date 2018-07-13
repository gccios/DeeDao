//
//  LiuYanTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "LiuYanTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import "UIView+LayerCurve.h"
#import "DDTool.h"
#import "UserInfoViewController.h"
#import <UIImageView+WebCache.h>

@interface LiuYanTableViewCell ()

@property (nonatomic, strong) CommentModel * model;
@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UILabel * detailLabel;

@end

@implementation LiuYanTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createLiuYanCell];
    }
    return self;
}

- (void)configWithModel:(CommentModel *)model
{
    self.model = model;
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.commentatorPic]];
    self.nameLabel.text = model.commentatorName;
    self.timeLabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:model.commentTime];
    self.detailLabel.text = model.commentContent;
}

- (void)logoImageViewDidClicked
{
    UITabBarController * tab = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)tab.selectedViewController;
    
    UserInfoViewController * info = [[UserInfoViewController alloc] initWithUserId:self.model.commentatorId];
    [na pushViewController:info animated:YES];
}

- (void)createLiuYanCell
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
        make.top.mas_equalTo(50 * scale);
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(48 * scale);
        make.height.mas_equalTo(55 * scale);
        make.right.mas_equalTo(-350 * scale);
    }];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:[UIColorFromRGB(0x000000) colorWithAlphaComponent:.54f] alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(70 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(40 * scale);
    }];
    
    self.detailLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:[UIColorFromRGB(0x000000) colorWithAlphaComponent:.54f] alignment:NSTextAlignmentLeft];
    self.detailLabel.numberOfLines = 0;
    [self.contentView addSubview:self.detailLabel];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(117 * scale);
        make.left.mas_equalTo(192 * scale);
        make.right.mas_equalTo(-96 * scale);
        make.bottom.mas_equalTo(-30 * scale);
    }];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 840 * scale, 2 * scale)];
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(840 * scale);
        make.height.mas_equalTo(2 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.bottom.mas_equalTo(0 * scale);
    }];
    [lineView layerDotteLinePoints:@[[NSValue valueWithCGPoint:CGPointMake(0, 0)], [NSValue valueWithCGPoint:CGPointMake(840 * scale, 0)]] Color:UIColorFromRGB(0x999999) Width:2 * scale SolidLength:3 * scale DotteLength:3 * scale];
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
