//
//  DDGroupPostTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2019/1/10.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DDGroupPostTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import "DDTool.h"

@interface DDGroupPostTableViewCell ()

@property (nonatomic, strong) DTieModel * model;
@property (nonatomic, strong) UIImageView * postImageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * poiLabel;
@property (nonatomic, strong) UILabel * statusLabel;
@property (nonatomic, strong) UILabel * postTitleLabel;

@property (nonatomic, strong) UIButton * applyButton;
@property (nonatomic, strong) UIButton * removeButton;
@property (nonatomic, strong) UIButton * toApplyButton;

@property (nonatomic, strong) UILabel * infoLabel;

@end

@implementation DDGroupPostTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createGroupPostCell];
    }
    return self;
}

- (void)configPostWithModel:(DTieModel *)model
{
    self.model = model;
    self.toApplyButton.hidden = NO;
    self.applyButton.hidden = YES;
    self.removeButton.hidden = YES;
    
    [self.postImageView sd_setImageWithURL:[NSURL URLWithString:model.postFirstPicture]];
    self.infoLabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:model.createTime];
    self.nameLabel.text = model.nickname;
    self.poiLabel.text = model.sceneAddress;
    self.postTitleLabel.text = model.postSummary;
}

- (void)configApplyWithModel:(DTieModel *)model
{
    self.model = model;
    self.toApplyButton.hidden = YES;
    self.applyButton.hidden = NO;
    self.removeButton.hidden = NO;
    
    [self.postImageView sd_setImageWithURL:[NSURL URLWithString:model.postFirstPicture]];
    self.infoLabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:model.createTime];
    self.nameLabel.text = model.nickname;
    self.poiLabel.text = model.sceneAddress;
    self.postTitleLabel.text = model.postSummary;
}

- (void)createGroupPostCell
{
    CGFloat scale = kMainBoundsWidth / 360.f;
    self.contentView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView * baseView = [[UIView alloc] initWithFrame:CGRectZero];
    baseView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.contentView addSubview:baseView];
    [baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-8 * scale);
    }];
    
    self.infoLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(14 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.infoLabel];
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(17 * scale);
        make.left.mas_equalTo(20 * scale);
        make.height.mas_equalTo(20 * scale);
        make.right.mas_equalTo(-20 * scale);
    }];
    
    UIView * BGView = [[UIView alloc] initWithFrame:CGRectZero];
    BGView.backgroundColor = UIColorFromRGB(0xffffff);
    [self.contentView addSubview:BGView];
    [BGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(50 * scale);
        make.left.mas_equalTo(20 * scale);
        make.width.height.mas_equalTo(80 * scale);
    }];
    BGView.layer.cornerRadius = 8;
    BGView.layer.shadowColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:0.3].CGColor;
    BGView.layer.shadowOffset = CGSizeMake(0,2);
    BGView.layer.shadowOpacity = 1;
    BGView.layer.shadowRadius = 8;
    
    self.postImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [BGView addSubview:self.postImageView];
    [self.postImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:8 withView:self.postImageView];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangMedium(16 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.postImageView.mas_right).offset(7 * scale);
        make.top.mas_equalTo(60 * scale);
        make.height.mas_equalTo(20 * scale);
        make.right.mas_equalTo(-20 * scale);
    }];
    
    self.poiLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(14 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.poiLabel];
    [self.poiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.postImageView.mas_right).offset(7 * scale);
        make.top.mas_equalTo(85 * scale);
        make.height.mas_equalTo(16 * scale);
        make.right.mas_equalTo(-20 * scale);
    }];
    
    self.postTitleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(14 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.postTitleLabel];
    [self.postTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.postImageView.mas_right).offset(7 * scale);
        make.top.mas_equalTo(103 * scale);
        make.height.mas_equalTo(16 * scale);
        make.right.mas_equalTo(-20 * scale);
    }];
    
    self.applyButton = [DDViewFactoryTool createButtonWithFrame: CGRectZero font:kPingFangRegular(14 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"批准"];
    [self.contentView addSubview:self.applyButton];
    [self.applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20 * scale);
        make.width.mas_equalTo(148 * scale);
        make.height.mas_equalTo(40 * scale);
        make.bottom.mas_equalTo(-30 * scale);
    }];
    [DDViewFactoryTool cornerRadius:20 * scale withView:self.applyButton];
    self.applyButton.layer.borderWidth = 1 * scale;
    self.applyButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    [self.applyButton addTarget:self action:@selector(handleButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.removeButton = [DDViewFactoryTool createButtonWithFrame: CGRectZero font:kPingFangRegular(14 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"移除"];
    [self.contentView addSubview:self.removeButton];
    [self.removeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20 * scale);
        make.width.mas_equalTo(148 * scale);
        make.height.mas_equalTo(40 * scale);
        make.bottom.mas_equalTo(-30 * scale);
    }];
    [DDViewFactoryTool cornerRadius:20 * scale withView:self.removeButton];
    self.removeButton.layer.borderWidth = 1 * scale;
    self.removeButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    [self.removeButton addTarget:self action:@selector(handleButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.toApplyButton = [DDViewFactoryTool createButtonWithFrame: CGRectZero font:kPingFangRegular(14 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"移到待审批"];
    [self.contentView addSubview:self.toApplyButton];
    [self.toApplyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20 * scale);
        make.left.mas_equalTo(20 * scale);
        make.height.mas_equalTo(40 * scale);
        make.bottom.mas_equalTo(-30 * scale);
    }];
    [DDViewFactoryTool cornerRadius:20 * scale withView:self.toApplyButton];
    self.toApplyButton.layer.borderWidth = 1 * scale;
    self.toApplyButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    [self.toApplyButton addTarget:self action:@selector(handleButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)handleButtonDidClicked:(UIButton *)button
{
    if (button == self.toApplyButton) {
        if (self.toApplyButtonHandle) {
            self.toApplyButtonHandle(self.model);
        }
    }else if (button == self.applyButton) {
        if (self.applyButtonHandle) {
            self.applyButtonHandle(self.model);
        }
    }else if (button == self.removeButton) {
        if (self.deleteButtonHandle) {
            self.deleteButtonHandle(self.model);
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
