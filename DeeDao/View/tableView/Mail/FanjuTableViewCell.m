//
//  FanjuTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/28.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "FanjuTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import "DDTool.h"

@interface FanjuTableViewCell ()

@property (nonatomic, strong) DTieModel * model;
@property (nonatomic, strong) UIImageView * postImageView;
@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * postTitleLabel;

@property (nonatomic, strong) UILabel * infoLabel;

@end

@implementation FanjuTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createFanjuCell];
    }
    return self;
}

- (void)configWithModel:(DTieModel *)model
{
    self.model = model;
    [self.postImageView sd_setImageWithURL:[NSURL URLWithString:model.postFirstPicture]];
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
    self.postTitleLabel.text = model.postSummary;
    
    NSString * build = model.sceneBuilding;
    if (isEmptyString(build)) {
        build = @"";
    }
    
    self.infoLabel.text = [NSString stringWithFormat:@"%@ %@", [DDTool getTimeWithFormat:@"yyyy年MM月dd日" time:model.sceneTime], build];
}

- (void)createFanjuCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.infoLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(38 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.infoLabel];
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(40 * scale);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(50 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    
    UIView * BGView = [[UIView alloc] initWithFrame:CGRectZero];
    BGView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:BGView];
    BGView.layer.cornerRadius = 24 * scale;
    BGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    BGView.layer.shadowOpacity = .3f;
    BGView.layer.shadowRadius = 8 * scale;
    BGView.layer.shadowOffset = CGSizeMake(0, 8 * scale);
    [BGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(140 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(606 * scale);
    }];
    
    UIView * coverView = [[UIView alloc] initWithFrame:CGRectZero];
    coverView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.contentView addSubview:coverView];
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(BGView.mas_bottom).offset(-24 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    self.postImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [BGView addSubview:self.postImageView];
    [self.postImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.postImageView];
    
    UIView * blackView = [[UIView alloc] initWithFrame:CGRectZero];
    blackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    [self.postImageView addSubview:blackView];
    [blackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-24 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    
    self.postTitleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentLeft];
    [blackView addSubview:self.postTitleLabel];
    [self.postTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(20 * scale);
        make.right.mas_equalTo(-20 * scale);
    }];
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [self.contentView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(BGView.mas_left).offset(-20 * scale);
        make.top.mas_equalTo(BGView).offset(-30 * scale);
        make.width.height.mas_equalTo(108 * scale);
    }];
    [DDViewFactoryTool cornerRadius:54 * scale withView:self.logoImageView];
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
