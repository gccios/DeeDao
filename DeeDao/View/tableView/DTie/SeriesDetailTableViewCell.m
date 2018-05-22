//
//  SeriesDetailTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SeriesDetailTableViewCell.h"
#import "DDHandleButton.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import "DDTool.h"
#import <UIImageView+WebCache.h>

@interface SeriesDetailTableViewCell()

@property (nonatomic, strong) UIImageView * coverImageView;
@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UILabel * detailLabel;
@property (nonatomic, strong) DDHandleButton * yaoyueButton;
@property (nonatomic, strong) DDHandleButton * shoucangButton;
@property (nonatomic, strong) DDHandleButton * dazhaohuButton;

@property (nonatomic, strong) UIButton * showButton;

@end

@implementation SeriesDetailTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createSeriesDetailCell];
    }
    return self;
}

- (void)createSeriesDetailCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.coverImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"test"]];
    [self.contentView addSubview:self.coverImageView];
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.top.mas_equalTo(48 * scale);
        make.width.mas_equalTo(384 * scale);
        make.height.mas_equalTo(641 * scale);
    }];
    [DDViewFactoryTool cornerRadius:12 * scale withView:self.coverImageView];
    self.coverImageView.layer.shadowColor = UIColorFromRGB(0x000000).CGColor;
    self.coverImageView.layer.shadowOpacity = .5f;
    self.coverImageView.layer.shadowOffset = CGSizeMake(0, 2 * scale);
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"test"]];
    [self.contentView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.coverImageView.mas_right).offset(48 * scale);
        make.top.mas_equalTo(181 * scale);
        make.width.height.mas_equalTo(96 * scale);
    }];
    [DDViewFactoryTool cornerRadius:48 * scale withView:self.logoImageView];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(43 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    self.nameLabel.text = @"Just丶DeeDao";
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(178 * scale);
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(24 * scale);
        make.height.mas_equalTo(54 * scale);
    }];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
    self.timeLabel.text = [DDTool getTimeStampMS];
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(10 * scale);
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(24 * scale);
        make.height.mas_equalTo(40 * scale);
    }];
    
    self.detailLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.detailLabel];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.coverImageView.mas_right).offset(48 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(48 * scale);
        make.height.mas_equalTo(216 * scale);
    }];
    
    self.yaoyueButton = [DDHandleButton buttonWithType:UIButtonTypeCustom];
    [self.yaoyueButton configImage:[UIImage imageNamed:@"yaoyue"]];
    [self.yaoyueButton configTitle:@"99+"];
    self.yaoyueButton.handleLabel.textColor = UIColorFromRGB(0x999999);
    [self.contentView addSubview:self.yaoyueButton];
    [self.yaoyueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.coverImageView.mas_right).offset(48 * scale);
        make.top.mas_equalTo(self.detailLabel.mas_bottom).offset(50 * scale);
        make.width.height.mas_equalTo(96 * scale);
    }];
    
    self.shoucangButton = [DDHandleButton buttonWithType:UIButtonTypeCustom];
    [self.shoucangButton configImage:[UIImage imageNamed:@"yaoyue"]];
    [self.shoucangButton configTitle:@"99+"];
    self.shoucangButton.handleLabel.textColor = UIColorFromRGB(0x999999);
    [self addSubview:self.shoucangButton];
    [self.shoucangButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.yaoyueButton.mas_right).offset(40 * scale);
        make.top.mas_equalTo(self.yaoyueButton);
        make.width.height.mas_equalTo(96 * scale);
    }];
    
    self.dazhaohuButton = [DDHandleButton buttonWithType:UIButtonTypeCustom];
    [self.dazhaohuButton configImage:[UIImage imageNamed:@"dazhaohu"]];
    [self.dazhaohuButton configTitle:@"99+"];
    self.dazhaohuButton.handleLabel.textColor = UIColorFromRGB(0x999999);
    [self addSubview:self.dazhaohuButton];
    [self.dazhaohuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.shoucangButton.mas_right).offset(40 * scale);
        make.top.mas_equalTo(self.yaoyueButton);
        make.width.height.mas_equalTo(96 * scale);
    }];
    
    self.showButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"查看D贴"];
    [self.showButton addTarget:self action:@selector(showButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.showButton];
    [self.contentView addSubview:self.showButton];
    [self.showButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(144 * scale);
        make.bottom.mas_equalTo(-5 * scale);
    }];
    self.showButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.showButton.layer.borderWidth = 3 * scale;
}

- (void)configWithModel:(DTieModel *)model
{
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.postFirstPicture]];
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
    self.nameLabel.text = model.nickname;
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString * createTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)model.updateTime / 1000]];
    self.timeLabel.text = createTime;
    
    [self.yaoyueButton configTitle:[NSString stringWithFormat:@"%ld", model.wyyCount]];
    [self.shoucangButton configTitle:[NSString stringWithFormat:@"%ld", model.collectCount]];
    [self.dazhaohuButton configTitle:[NSString stringWithFormat:@"%ld", model.dzfCount]];
}

- (void)showButtonDidClicked
{
    if (self.seriesShowDTieHandle) {
        self.seriesShowDTieHandle();
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
