//
//  MainInfoTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/19.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "MainInfoTableViewCell.h"
#import <Masonry.h>
#import "DDViewFactoryTool.h"

@interface MainInfoTableViewCell ()

@property (nonatomic, strong) UILabel * infoLabel;
@property (nonatomic, strong) UILabel * timeLabel;

@end

@implementation MainInfoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createMainInfoCell];
    }
    return self;
}

- (void)createMainInfoCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [self.contentView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(120 * scale);
        make.right.mas_equalTo(-120 * scale);
        make.bottom.mas_equalTo(-70 * scale);
    }];
    imageView.layer.borderColor = UIColorFromRGB(0xCCCCCC).CGColor;
    imageView.layer.borderWidth = 3 * scale;
    
    self.infoLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(40 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    self.infoLabel.numberOfLines = 0;
    [self.contentView addSubview:self.infoLabel];
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(38 * scale);
        make.left.mas_equalTo(180 * scale);
        make.bottom.mas_equalTo(-118 * scale);
        make.right.mas_equalTo(-180 * scale);
    }];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(120 * scale);
        make.right.mas_equalTo(-120 * scale);
        make.height.mas_equalTo(40 * scale);
        make.bottom.mas_equalTo(-10 * scale);
    }];
}

- (void)configInfo:(NSString *)info time:(NSString *)time
{
    if (isEmptyString(info)) {
        self.infoLabel.text = @"暂无消息内容";
    }else{
        self.infoLabel.text = info;
    }
    self.timeLabel.text = time;
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
