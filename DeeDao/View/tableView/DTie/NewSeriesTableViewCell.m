//
//  NewSeriesTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/7.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "NewSeriesTableViewCell.h"
#import <Masonry.h>
#import "DDViewFactoryTool.h"
#import <UIImageView+WebCache.h>
#import "DDTool.h"

@interface NewSeriesTableViewCell ()

@property (nonatomic, strong) UIImageView * postImageView;
@property (nonatomic, strong) UILabel * postNameLabel;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UILabel * addressLabel;

@end

@implementation NewSeriesTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createNewSeriesTableViewCell];
    }
    return self;
}

- (void)configWithModel:(DTieModel *)model
{
    [self.postImageView sd_setImageWithURL:[NSURL URLWithString:model.postFirstPicture]];
    self.postNameLabel.text = model.postSummary;
    self.timeLabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:model.sceneTime];
    self.addressLabel.text = model.sceneAddress;
}

- (void)createNewSeriesTableViewCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIView * topView = [[UIView alloc] initWithFrame:CGRectZero];
    topView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.contentView addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(24 * scale);
    }];
    
    UIView * baseView = [[UIView alloc] initWithFrame:CGRectZero];
    baseView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.contentView addSubview:baseView];
    [baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(24 * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    self.postImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [baseView addSubview:self.postImageView];
    [self.postImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(36 * scale);
        make.left.mas_equalTo(60 * scale);
        make.width.mas_equalTo(360 * scale);
        make.height.mas_equalTo(216 * scale);
    }];
    self.postImageView.clipsToBounds = YES;
    
    UIView * titleView = [[UIView alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    [self.postImageView addSubview:titleView];
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(72 * scale);
    }];
    
    self.postNameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentLeft];
    [titleView addSubview:self.postNameLabel];
    [self.postNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(10 * scale);
        make.right.mas_equalTo(-10 * scale);
    }];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [baseView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(60 * scale);
        make.left.mas_equalTo(self.postImageView.mas_right).offset(48 * scale);
        make.right.mas_equalTo(-48 * scale);
    }];
    
    self.addressLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.addressLabel.numberOfLines = 3;
    [baseView addSubview:self.addressLabel];
    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(14 * scale);
        make.left.mas_equalTo(self.postImageView.mas_right).offset(48 * scale);
        make.right.mas_equalTo(-48 * scale);
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
