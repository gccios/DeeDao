//
//  DaZhaoHuTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DaZhaoHuTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import "UIView+LayerCurve.h"
#import "DDTool.h"
#import "UserInfoViewController.h"
#import <UIImageView+WebCache.h>

@interface DaZhaoHuTableViewCell ()

@property (nonatomic, strong) UserDaZhaoHuModel * model;
@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * timeLabel;

@end

@implementation DaZhaoHuTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createLiuYanCell];
    }
    return self;
}

- (void)configWithModel:(UserDaZhaoHuModel *)model
{
    self.model = model;
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
    self.nameLabel.text = model.nickname;
    self.timeLabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:model.createTime];
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
    [headerBGView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo(96 * scale);
    }];
    [DDViewFactoryTool cornerRadius:48 * scale withView:self.logoImageView];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0x00000) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(48 * scale);
        make.height.mas_equalTo(55 * scale);
        make.right.mas_equalTo(-350 * scale);
    }];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:[UIColorFromRGB(0x000000) colorWithAlphaComponent:.54f] alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(40 * scale);
    }];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 840 * scale, 2 * scale)];
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(2 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.bottom.mas_equalTo(0 * scale);
    }];
    [lineView layerDotteLinePoints:@[[NSValue valueWithCGPoint:CGPointMake(0, 0)], [NSValue valueWithCGPoint:CGPointMake(960 * scale, 0)]] Color:UIColorFromRGB(0x999999) Width:2 * scale SolidLength:4 * scale DotteLength:8 * scale];
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
