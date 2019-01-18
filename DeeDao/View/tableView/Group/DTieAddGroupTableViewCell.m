//
//  DTieAddGroupTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2019/1/14.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DTieAddGroupTableViewCell.h"
#import "DDViewFactoryTool.h"
#import "DDTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import "UserManager.h"

@interface DTieAddGroupTableViewCell ()

@property (nonatomic, strong) DDGroupModel * model;

@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UILabel * infoLabel;
@property (nonatomic, strong) UILabel * managerLabel;

@property (nonatomic, strong) UIButton * defaultButton;
@property (nonatomic, strong) UIButton * addButton;
@property (nonatomic, strong) UIButton * cancleButton;

@end

@implementation DTieAddGroupTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self createAddGroupCell];
    }
    return self;
}

- (void)configWithModel:(DDGroupModel *)model DtieModel:(nonnull DTieModel *)dtie
{
    self.model = model;
    
    self.timeLabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日  HH:mm" time:model.groupCreateDate];
    self.nameLabel.text = model.groupName;
    self.infoLabel.text = model.remark;
    self.managerLabel.text = model.managerName;
    
    if (model.isSystem) {
        if (model.cid == -1) {
            [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.groupPic]];
            self.defaultButton.hidden = NO;
            self.addButton.hidden = YES;
            self.cancleButton.hidden = YES;
        }else if (model.cid == -2) {
            [self.logoImageView setImage:[UIImage imageNamed:model.groupPic]];
            
            if (dtie.landAccountFlg == 1) {
                self.defaultButton.hidden = YES;
                self.addButton.hidden = YES;
                self.cancleButton.hidden = NO;
            }else{
                self.defaultButton.hidden = YES;
                self.addButton.hidden = NO;
                self.cancleButton.hidden = YES;
            }
            
        }else{
            self.defaultButton.hidden = NO;
            self.addButton.hidden = YES;
            self.cancleButton.hidden = YES;
        }
    }else{
        [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.groupPic]];
        if (model.postFlag == 0) {
            self.defaultButton.hidden = YES;
            self.addButton.hidden = NO;
            self.cancleButton.hidden = YES;
        }else{
            self.defaultButton.hidden = YES;
            self.addButton.hidden = YES;
            self.cancleButton.hidden = NO;
        }
    }
}

- (void)createAddGroupCell
{
    CGFloat scale = kMainBoundsWidth / 360.f;
    
    self.contentView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.contentView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-15 * scale);
    }];
    
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectZero];
    bgView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    bgView.layer.cornerRadius = 8*scale;
    bgView.layer.shadowColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:0.3].CGColor;
    bgView.layer.shadowOffset = CGSizeMake(0,2);
    bgView.layer.shadowOpacity = 1;
    bgView.layer.shadowRadius = 8*scale;
    [contentView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(20 * scale);
        make.width.height.mas_equalTo(80 * scale);
    }];
    
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    self.logoImageView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [DDViewFactoryTool cornerRadius:8 * scale withView:self.logoImageView];
    [bgView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangMedium(16 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.nameLabel.text = @"群名称";
    [contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(22 * scale);
        make.left.mas_equalTo(bgView.mas_right).offset(15 * scale);
        make.right.mas_equalTo(-20 * scale);
    }];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(14 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.timeLabel.text = @"群创建时间";
    [contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(46 * scale);
        make.left.mas_equalTo(bgView.mas_right).offset(15 * scale);
        make.right.mas_equalTo(-20 * scale);
    }];
    
    self.infoLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(14 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.infoLabel.text = @"群描述";
    [contentView addSubview:self.infoLabel];
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(65 * scale);
        make.left.mas_equalTo(bgView.mas_right).offset(15 * scale);
        make.right.mas_equalTo(-20 * scale);
    }];
    
    self.managerLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(14 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.managerLabel.text = @"群管理员";
    [contentView addSubview:self.managerLabel];
    [self.managerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(83 * scale);
        make.left.mas_equalTo(bgView.mas_right).offset(15 * scale);
        make.right.mas_equalTo(-20 * scale);
    }];
    
    self.defaultButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(14 * scale) titleColor:UIColorFromRGB(0xDDDDDD) title:@"系统默认必选群"];
    [contentView addSubview:self.defaultButton];
    [self.defaultButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.mas_equalTo(320 * scale);
        make.height.mas_equalTo(40 * scale);
    }];
    [DDViewFactoryTool cornerRadius:20 * scale withView:self.defaultButton];
    self.defaultButton.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
    self.defaultButton.layer.borderWidth = 1;
    self.defaultButton.enabled = NO;
    self.defaultButton.hidden = YES;
    
    self.cancleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(14 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"取消投放"];
    [contentView addSubview:self.cancleButton];
    [self.cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.mas_equalTo(320 * scale);
        make.height.mas_equalTo(40 * scale);
    }];
    [DDViewFactoryTool cornerRadius:20 * scale withView:self.cancleButton];
    self.cancleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.cancleButton.layer.borderWidth = 1;
    self.cancleButton.hidden = YES;
    [self.cancleButton addTarget:self action:@selector(handleButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.addButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(14 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"投放到此群"];
    [contentView addSubview:self.addButton];
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.mas_equalTo(320 * scale);
        make.height.mas_equalTo(40 * scale);
    }];
    [DDViewFactoryTool cornerRadius:20 * scale withView:self.cancleButton];
    [self.addButton addTarget:self action:@selector(handleButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, 320 * scale, 40 * scale);
    gradientLayer.cornerRadius = 20 * scale;
    [self.addButton.layer insertSublayer:gradientLayer atIndex:0];
}

- (void)handleButtonDidClicked:(UIButton *)button
{
    if (button == self.addButton) {
        
        if (self.addButtonHandle) {
            self.addButtonHandle(self.model);
        }
        
    }else if (button == self.cancleButton) {
        
        if (self.cancleButtonHandle) {
            self.cancleButtonHandle(self.model);
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
