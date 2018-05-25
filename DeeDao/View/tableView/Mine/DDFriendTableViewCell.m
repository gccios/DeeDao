//
//  DDFriendTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/14.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDFriendTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>

@interface DDFriendTableViewCell ()

@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * degreeLabel;
@property (nonatomic, strong) UIImageView * starImageView;

@end

@implementation DDFriendTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self  = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createFriendCell];
    }
    return self;
}

- (void)configWithModel:(UserModel *)model
{
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
    self.nameLabel.text = model.nickname;
}

- (void)createFriendCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.starImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"starFull"]];
    [self.contentView addSubview:self.starImageView];
    [self.starImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
        make.centerY.mas_equalTo(-3 * scale);
        make.width.height.mas_equalTo(40 * scale);
    }];
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"DeeDao-logo"]];
    [self.contentView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.centerY.mas_equalTo(0 * scale);
        make.width.height.mas_equalTo(120 * scale);
    }];
    [DDViewFactoryTool cornerRadius:60 * scale withView:self.logoImageView];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0x000000) alignment:NSTextAlignmentLeft];
    self.nameLabel.text = @"Just丶Dee Dao";
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(20 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(50 * scale);
    }];
    
    self.degreeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x3F3F3F) alignment:NSTextAlignmentLeft];
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:@"吻合度：" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x3F3F3F)}];
    
    NSAttributedString * degree = [[NSAttributedString alloc] initWithString:@"100%" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0xDB6283)}];
    
    [string appendAttributedString:degree];
    self.degreeLabel.attributedText = string;
    [self.contentView addSubview:self.degreeLabel];
    [self.degreeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(self.starImageView.mas_left).offset(-20 * scale);
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
