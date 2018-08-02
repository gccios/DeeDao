//
//  NotificationListCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/2.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "NotificationListCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>

@interface NotificationListCell ()

@property (nonatomic, strong) UIImageView * postImageView;
@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * postNameLabel;
@property (nonatomic, strong) UILabel * postAddressLabel;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UIButton * settingButton;

@end

@implementation NotificationListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self createNotificationCell];
        
    }
    return self;
}

- (void)createNotificationCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView * postBGView = [[UIView alloc] initWithFrame:CGRectZero];
    postBGView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:postBGView];
    [postBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(66 * scale);
        make.top.mas_equalTo(84 * scale);
        make.width.mas_equalTo(450 * scale);
        make.bottom.mas_equalTo(0);
    }];
    postBGView.layer.cornerRadius = 24 * scale;
    postBGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    postBGView.layer.shadowOpacity = .5f;
    postBGView.layer.shadowRadius = 8 * scale;
    postBGView.layer.shadowOffset = CGSizeMake(0, 4 * scale);
    
    self.postImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [postBGView addSubview:self.postImageView];
    [self.postImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.postImageView];
    
    UIView * postNameView = [[UIView alloc] initWithFrame:CGRectZero];
    postNameView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    [self.postImageView addSubview:postNameView];
    [postNameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-24 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    
    self.postNameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0XFFFFFF) alignment:NSTextAlignmentLeft];
    [postNameView addSubview:self.postNameLabel];
    [self.postNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(25 * scale);
        make.right.mas_equalTo(-20 * scale);
        make.top.bottom.mas_equalTo(0);
    }];
    
    UIView * logoBGView = [[UIView alloc] initWithFrame:CGRectZero];
    logoBGView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:logoBGView];
    [logoBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(postBGView.mas_left).offset(-20 * scale);
        make.top.mas_equalTo(30 * scale);
        make.width.height.mas_equalTo(96 * scale);
    }];
    logoBGView.layer.cornerRadius = 48 * scale;
    logoBGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    logoBGView.layer.shadowOpacity = .5f;
    logoBGView.layer.shadowRadius = 6 * scale;
    logoBGView.layer.shadowOffset = CGSizeMake(0, 3 * scale);
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [logoBGView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:48 * scale withView:self.logoImageView];
    
    self.postAddressLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    self.postAddressLabel.text = @"D帖的POI";
    [self.contentView addSubview:self.postAddressLabel];
    [self.postAddressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(100 * scale);
        make.left.mas_equalTo(postBGView.mas_right).offset(58 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    self.timeLabel.text = @"时间";
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.postAddressLabel.mas_bottom).offset(15 * scale);
        make.left.mas_equalTo(self.postAddressLabel);
        make.right.mas_equalTo(self.postAddressLabel);
    }];
    
    self.settingButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@" 不再提醒 "];
    [self.contentView addSubview:self.settingButton];
    [self.settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(15 * scale);
        make.left.mas_equalTo(self.postAddressLabel);
        make.height.mas_equalTo(72 * scale);
    }];
    [DDViewFactoryTool cornerRadius:36 * scale withView:self.settingButton];
    self.settingButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.settingButton.layer.borderWidth = 3 * scale;
    
    UIView * coverView = [[UIView alloc] initWithFrame:CGRectZero];
    coverView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.contentView addSubview:coverView];
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(24 * scale);
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
