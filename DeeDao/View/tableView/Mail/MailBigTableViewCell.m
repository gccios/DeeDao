//
//  MailBigTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/14.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "MailBigTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>

@interface MailBigTableViewCell ()

@property (nonatomic, strong) UIImageView * coverImageView;

@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UIImageView * topImageView;
@property (nonatomic, strong) UIView * baseView;
@property (nonatomic, strong) UILabel * InfoLabel;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * timeLabel;

@end

@implementation MailBigTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createBigMailCell];
    }
    return self;
}

- (void)createBigMailCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.backgroundColor = UIColorFromRGB(0xEFEFF4);
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.baseView];
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(54 * scale);
        make.left.mas_equalTo(54 * scale);
        make.right.mas_equalTo(-54 * scale);
        make.bottom.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:50 * scale withView:self.baseView];
    
    UIImage * bgImage = [UIImage imageNamed:@"bigkuang"];
    self.coverImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleToFill image:[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(bgImage.size.height*0.9, bgImage.size.width*0.9, bgImage.size.height*0.9, bgImage.size.width*0.9) resizingMode:UIImageResizingModeStretch]];
    self.coverImageView.layer.masksToBounds = YES;
    [self.baseView addSubview:self.coverImageView];
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(0);
    }];
    
    self.topImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"test"]];
    self.topImageView.layer.masksToBounds = YES;
    [self.baseView addSubview:self.topImageView];
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(13 * scale);
        make.right.mas_equalTo(-10 * scale);
        make.left.mas_equalTo(115 * scale);
        make.height.mas_equalTo(288 * scale);
    }];
//    [DDViewFactoryTool cornerRadius:24 * scale withView:self.topImageView];
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"yt_message"]];
    [self.baseView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(66 * scale);
        make.centerY.mas_equalTo(-12 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    self.InfoLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0x000000) alignment:NSTextAlignmentLeft];
    self.InfoLabel.text = @"在你的D贴的位置向你打招呼";
    [self.baseView addSubview:self.InfoLabel];
    [self.InfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topImageView.mas_bottom).offset(20 * scale);
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(35 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x444444) alignment:NSTextAlignmentLeft];
    self.nameLabel.text = @"Just丶DeeDao";
    [self.baseView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.InfoLabel.mas_bottom).offset(15 * scale);
        make.left.mas_equalTo(self.InfoLabel);
        make.height.mas_equalTo(45 * scale);
    }];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x444444) alignment:NSTextAlignmentLeft];
    self.timeLabel.text = @"22:36 PM";
    [self.baseView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel);
        make.right.mas_equalTo(-45 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
    
    UIView * coverView = [[UIView alloc] initWithFrame:CGRectZero];
    coverView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.contentView addSubview:coverView];
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(30 * scale);
    }];
    coverView.layer.shadowColor = UIColorFromRGB(0x333333).CGColor;
    coverView.layer.shadowOpacity = .2f;
    coverView.layer.shadowOffset = CGSizeMake(0, -12 * scale);
}

- (void)configWithModel:(MailModel *)model
{
    
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
