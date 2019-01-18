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
#import "DDGroupRequest.h"
#import "MBProgressHUD+DDHUD.h"
#import <UIImageView+WebCache.h>
#import "DDTool.h"

@interface DDGroupTableViewCell ()

@property (nonatomic, strong) DDGroupModel * model;

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

- (void)configWithMyGroupWithModel:(DDGroupModel *)model
{
    self.model = model;
    
    self.rightButton.hidden = NO;
    [self.leftButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(148 * kMainBoundsWidth / 360.f);
    }];
    [self.leftButton setTitle:@"列表浏览" forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"listliulan"] forState:UIControlStateNormal];
    
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.groupPic]];
    self.timeLabel.text = [DDTool getTimeWithFormat:@"创建于：yyyy年MM月dd日" time:model.groupCreateDate];
    self.nameLabel.text = model.groupName;
    self.infoLabel.text = model.remark;
    
//    if (model.isSystem) {
//        self.tagLabel.hidden = NO;
//        self.tagLabel.text = @"【系统】";
//    }else{
//        self.tagLabel.hidden = YES;
//    }
}

- (void)configWithOtherPublicWithModel:(DDGroupModel *)model
{
    self.model = model;
    
    self.rightButton.hidden = YES;
    
    [self.leftButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kMainBoundsWidth - 40 * kMainBoundsWidth / 360.f);
    }];
    [self.leftButton setTitle:@"申请加入" forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"applyGroup"] forState:UIControlStateNormal];
    [self.leftButton addTarget:self action:@selector(applyButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.groupPic]];
    self.timeLabel.text = [DDTool getTimeWithFormat:@"创建于：yyyy年MM月dd日" time:model.groupCreateDate];
    self.nameLabel.text = model.groupName;
    self.infoLabel.text = model.remark;
    
    self.tagLabel.hidden = NO;
//    self.tagLabel.text = @"1人参与";
}

- (void)applyButtonDidClicked
{
    DDGroupRequest * request = [[DDGroupRequest alloc] initApplyPeopleWithGroupID:self.model.cid];
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在申请" inView:[UIApplication sharedApplication].keyWindow];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"申请成功" inView:[UIApplication sharedApplication].keyWindow];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        NSString * msg = [response objectForKey:@"msg"];
        if (isEmptyString(msg)) {
            msg = @"申请失败";
        }
        [MBProgressHUD showTextHUDWithText:msg inView:[UIApplication sharedApplication].keyWindow];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"申请失败" inView:[UIApplication sharedApplication].keyWindow];
        
    }];
}

- (void)createGroupCell
{
    CGFloat scale = kMainBoundsWidth / 360.f;
    
    self.contentView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.contentView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(215 * scale);
    }];
    
    UIView * BGView = [[UIView alloc] initWithFrame:CGRectZero];
    BGView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [contentView addSubview:BGView];
    [BGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(53 * scale);
        make.left.mas_equalTo(20 * scale);
        make.width.height.mas_equalTo(80 * scale);
    }];
    BGView.layer.cornerRadius = 8;
    BGView.layer.shadowColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:0.3].CGColor;
    BGView.layer.shadowOffset = CGSizeMake(0,2);
    BGView.layer.shadowOpacity = 1;
    BGView.layer.shadowRadius = 8;
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [BGView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:8 withView:self.logoImageView];
    
    self.updateLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(14 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
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
    self.xinLabel.hidden = YES;
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(16 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
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
//    self.tagLabel.text = @"系统";
    [contentView addSubview:self.tagLabel];
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(9 * scale);
        make.left.mas_equalTo(self.timeLabel.mas_right).offset(15 * scale);
        make.height.mas_equalTo(15 * scale);
    }];
    
    self.infoLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(14 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
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
    [self.leftButton addTarget:self action:@selector(handleButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.rightButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(14 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"地图浏览"];
    [self.rightButton setImage:[UIImage imageNamed:@"mapliulan"] forState:UIControlStateNormal];
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
    [self.rightButton addTarget:self action:@selector(handleButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)handleButtonDidClicked:(UIButton *)button
{
    if (button == self.leftButton) {
        if (self.listButtonHandle) {
            self.listButtonHandle(self.model);
        }
    }else if (button == self.rightButton) {
        if (self.mapButtonHandle) {
            self.mapButtonHandle(self.model);
        }
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
