//
//  SeriesSelectTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SeriesSelectTableViewCell.h"
#import <Masonry.h>
#import "DDViewFactoryTool.h"

@interface SeriesSelectTableViewCell ()

@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UIImageView * selectImageView;

@end

@implementation SeriesSelectTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createSeriesSelectCell];
    }
    return self;
}

- (void)configSelectStatus:(BOOL)status
{
    if (status) {
        [self.selectImageView setImage:[UIImage imageNamed:@"chooseyes"]];
    }else{
        [self.selectImageView setImage:[UIImage imageNamed:@"chooseno"]];
    }
}

- (void)configWithSeriesModel:(SeriesModel *)model
{
    self.nameLabel.text = model.seriesTitle;
}

- (void)createSeriesSelectCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-200 * scale);
    }];
    
    self.selectImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [self.contentView addSubview:self.selectImageView];
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-48 * scale);
        make.width.height.mas_equalTo(72 * scale);
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
