//
//  DDGroupTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2019/1/7.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DDGroupTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>

@interface DDGroupTableViewCell ()

@property (nonatomic, strong) UILabel * xinLabel;

@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * updateLabel;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UILabel * tagLabel;
@property (nonatomic, strong) UILabel * infoLabel;

@property (nonatomic, strong) UIButton * leftButton;
@property (nonatomic, strong) UIButton * rightButton;

@end

@implementation DDGroupTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createGroupCell];
    }
    return self;
}

- (void)createGroupCell
{
    CGFloat scale = kMainBoundsWidth / 360.f;
    
    self.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.contentView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(215 * scale);
    }];
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    self.logoImageView.backgroundColor = [UIColor redColor];
//    [DDViewFactoryTool cornerRadius:8 * scale withView:self.logoImageView];
    [contentView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(53 * scale);
        make.left.mas_equalTo(20 * scale);
        make.width.height.mas_equalTo(80 * scale);
    }];
    self.logoImageView.layer.cornerRadius = 8;
    self.logoImageView.layer.shadowColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:0.3].CGColor;
    self.logoImageView.layer.shadowOffset = CGSizeMake(0,2);
    self.logoImageView.layer.shadowOpacity = 1;
    self.logoImageView.layer.shadowRadius = 8;
    
    self.updateLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(14 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.updateLabel.text = @"更新于：2018年12月21日 20:00 星期一";
    [contentView addSubview:self.updateLabel];
    [self.updateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(20 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(20 * scale);
    }];
    
    self.xinLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangLight(8 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentCenter];
    self.xinLabel.text = @"NEW";
    self.xinLabel.backgroundColor = UIColorFromRGB(0xFC6E60);
    [contentView addSubview:self.xinLabel];
    [self.xinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.updateLabel);
        make.left.mas_equalTo(self.updateLabel.mas_right).offset(15 * scale);
        make.width.mas_equalTo(25 * scale);
        make.height.mas_equalTo(14 * scale);
    }];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(16 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.nameLabel.text = @"群名称";
    [contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(61 * scale);
        make.left.mas_equalTo(116 * scale);
        make.height.mas_equalTo(20 * scale);
        make.right.mas_equalTo(-15 * scale);
    }];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(14 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
    self.timeLabel.text = @"2018年12月建立";
    [contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(9 * scale);
        make.left.mas_equalTo(self.nameLabel);
        make.height.mas_equalTo(15 * scale);
    }];
    
    self.tagLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(14 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
    self.tagLabel.text = @"系统";
    [contentView addSubview:self.tagLabel];
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(9 * scale);
        make.left.mas_equalTo(self.timeLabel.mas_right).offset(15 * scale);
        make.height.mas_equalTo(15 * scale);
    }];
    
    self.infoLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(14 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.infoLabel.text = @"一个只属于你自己的小天地";
    [contentView addSubview:self.infoLabel];
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(3 * scale);
        make.left.mas_equalTo(self.timeLabel);
        make.height.mas_equalTo(15 * scale);
    }];
    
    self.leftButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(14 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"列表浏览"];
    [DDViewFactoryTool cornerRadius:20 * scale withView:self.leftButton];
    self.leftButton.layer.borderWidth = 1;
    self.leftButton.layer.borderColor = [UIColor colorWithRed:219/255.0 green:98/255.0 blue:131/255.0 alpha:1.0].CGColor;
    [contentView addSubview:self.leftButton];
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.mas_equalTo(148 * scale);
        make.height.mas_equalTo(40 * scale);
    }];
    
    self.rightButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(14 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"地图浏览"];
    [DDViewFactoryTool cornerRadius:20 * scale withView:self.rightButton];
    self.rightButton.layer.borderWidth = 1;
    self.rightButton.layer.borderColor = [UIColor colorWithRed:219/255.0 green:98/255.0 blue:131/255.0 alpha:1.0].CGColor;
    [contentView addSubview:self.rightButton];
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.mas_equalTo(148 * scale);
        make.height.mas_equalTo(40 * scale);
    }];
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
