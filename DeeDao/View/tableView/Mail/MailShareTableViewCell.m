//
//  MailShareTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/14.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "MailShareTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import "DDTool.h"
#import <UIImageView+WebCache.h>

@interface MailShareTableViewCell ()

@property (nonatomic, strong) UIView * baseView;
@property (nonatomic, strong) UIView * userView;

@property (nonatomic, strong) UIImageView * coverImageView;
@property (nonatomic, strong) UIImageView * logoImageView;

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * InfoLabel;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * timeLabel;

@end

@implementation MailShareTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createMailShareCell];
    }
    return self;
}

- (void)createMailShareCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.backgroundColor = UIColorFromRGB(0xEFEFF4);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.baseView];
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(54 * scale);
        make.left.mas_equalTo(54 * scale);
        make.right.mas_equalTo(-54 * scale);
        make.bottom.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.baseView];
    self.baseView.layer.borderColor = UIColorFromRGB(0xCCCCCC).CGColor;
    self.baseView.layer.borderWidth = 6 * scale;
    
    self.coverImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"test"]];
    self.coverImageView.layer.masksToBounds = YES;
    [self.baseView addSubview:self.coverImageView];
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(288 * scale);
    }];
    
    UIView * blackView = [[UIView alloc] initWithFrame:CGRectZero];
    blackView.backgroundColor = [UIColorFromRGB(0x111111) colorWithAlphaComponent:.7f];
    [self.coverImageView addSubview:blackView];
    [blackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(84 * scale);
    }];
    
    self.titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0XFFFFFF) alignment:NSTextAlignmentLeft];
//    self.titleLabel.text = @"这是一个标题";
    [blackView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.right.mas_equalTo(-30 * scale);
        make.top.bottom.mas_equalTo(0);
    }];
    
    self.userView = [[UIView alloc] initWithFrame:CGRectZero];
    self.userView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.baseView addSubview:self.userView];
    [self.userView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.coverImageView.mas_bottom);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    UIView * coverView = [[UIView alloc] initWithFrame:CGRectZero];
    coverView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.contentView addSubview:coverView];
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(24 * scale);
    }];
    coverView.layer.shadowColor = UIColorFromRGB(0x333333).CGColor;
    coverView.layer.shadowOpacity = .2f;
    coverView.layer.shadowOffset = CGSizeMake(0, -12 * scale);
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [self.userView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(30 * scale);
        make.left.mas_equalTo(60 * scale);
        make.width.height.mas_equalTo(96 * scale);
    }];
    [DDViewFactoryTool cornerRadius:96 * scale / 2 withView:self.logoImageView];
    
    self.InfoLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0x000000) alignment:NSTextAlignmentLeft];
//    self.InfoLabel.text = @"分享了一个D帖/系列给你";
    [self.userView addSubview:self.InfoLabel];
    [self.InfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(25 * scale);
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(45 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x444444) alignment:NSTextAlignmentLeft];
//    self.timeLabel.text = @"22:36 PM";
    [self.userView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.InfoLabel.mas_bottom).offset(15 * scale);
        make.right.mas_equalTo(-45 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x444444) alignment:NSTextAlignmentLeft];
    //    self.nameLabel.text = @"Just丶DeeDao";
    [self.userView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.InfoLabel.mas_bottom).offset(15 * scale);
        make.left.mas_equalTo(self.InfoLabel);
        make.right.mas_equalTo(self.timeLabel.mas_left).offset(-10 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
}

- (void)configWithModel:(MailModel *)model
{
    self.titleLabel.text = model.mailTitle;
    self.InfoLabel.text = model.mailContent;
    self.nameLabel.text = model.nickName;
    self.timeLabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:model.updateTime];
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraitUri]];
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
