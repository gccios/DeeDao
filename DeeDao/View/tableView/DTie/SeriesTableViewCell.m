//
//  SeriesTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SeriesTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>

@interface SeriesTableViewCell ()

@property (nonatomic, strong) UIView * baseView;

@property (nonatomic, strong) UIImageView * showImageView;
@property (nonatomic, strong) UILabel * showTitleLabel;

@property (nonatomic, strong) UIImageView * editImageView;
@property (nonatomic, strong) UILabel * editTitleLabel;

@end

@implementation SeriesTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createSeriesCell];
    }
    return self;
}

- (void)configWithModel:(SeriesModel *)model
{
    self.showTitleLabel.text = model.seriesTitle;
    self.editTitleLabel.text = model.seriesTitle;
    if (!isEmptyString(model.seriesFirstPicture)) {
        [self.showImageView sd_setImageWithURL:[NSURL URLWithString:model.seriesFirstPicture]];
        [self.editImageView sd_setImageWithURL:[NSURL URLWithString:model.seriesFirstPicture]];
    }
    
    if (model.seriesStatus) {
        self.editImageView.hidden = NO;
        self.showImageView.hidden = YES;
    }else{
        self.editImageView.hidden = YES;
        self.showImageView.hidden = NO;
    }
}

- (void)createSeriesCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.backgroundColor = UIColorFromRGB(0xEFEFF4);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectZero];
    self.baseView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.contentView addSubview:self.baseView];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.baseView];
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.bottom.mas_equalTo(-10 * scale);
    }];
    self.baseView.layer.shadowColor = UIColorFromRGB(0x000000).CGColor;
    self.baseView.layer.shadowOpacity = .5f;
    self.baseView.layer.shadowOffset = CGSizeMake(0, 2 * scale);
    
    //show
    self.showImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"test"]];
    [self.baseView addSubview:self.showImageView];
    [self.showImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-24 * scale);
    }];
    UIView * showBlackView = [[UIView alloc] initWithFrame:CGRectZero];
    showBlackView.backgroundColor = [UIColorFromRGB(0x111111) colorWithAlphaComponent:.6f];
    [self.showImageView addSubview:showBlackView];
    [showBlackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(84 * scale);
    }];
    self.showTitleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentLeft];
    self.showTitleLabel.text = @"这不仅仅是一个标题，而是一个系列的标题";
    [showBlackView addSubview:self.showTitleLabel];
    [self.showTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(24 * scale);
        make.right.mas_equalTo(-25 * scale);
        make.height.mas_equalTo(40 * scale);
        make.centerY.mas_equalTo(0);
    }];
    
    
    //edit
    self.editImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"test"]];
    [self.baseView addSubview:self.editImageView];
    [self.editImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-24 * scale);
    }];
    UIView * editBlackView = [[UIView alloc] initWithFrame:CGRectZero];
    editBlackView.backgroundColor = [UIColorFromRGB(0x111111) colorWithAlphaComponent:.6f];
    [self.editImageView addSubview:editBlackView];
    [editBlackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    self.editTitleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentLeft];
    self.editTitleLabel.text = @"这不仅仅是一个标题，而是一个系列的标题";
    [editBlackView addSubview:self.editTitleLabel];
    [self.editTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(24 * scale);
        make.right.mas_equalTo(-25 * scale);
        make.height.mas_equalTo(40 * scale);
        make.bottom.mas_equalTo(-22 * scale);
    }];
    UIImageView * editIcon = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"DTieEdit"]];
    [editBlackView addSubview:editIcon];
    [editIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(78 * scale);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(72 * scale);
    }];
    
    UIView * coverView = [[UIView alloc] initWithFrame:CGRectZero];
    coverView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.contentView addSubview:coverView];
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.baseView.mas_bottom).offset(-24 * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(24 * scale);
    }];
    coverView.layer.shadowColor = UIColorFromRGB(0x9B9B9B).CGColor;
    coverView.layer.shadowOpacity = .2f;
    coverView.layer.shadowOffset = CGSizeMake(0, -12 * scale);
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
