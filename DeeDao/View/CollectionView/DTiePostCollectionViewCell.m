//
//  DTiePostCollectionViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/26.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTiePostCollectionViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import "DDTool.h"
#import <UIImageView+WebCache.h>

@interface DTiePostCollectionViewCell ()

@property (nonatomic, strong) UIView * baseView;
@property (nonatomic, strong) UIImageView * postImageView;
@property (nonatomic, strong) UILabel * postNameLabel;
@property (nonatomic, strong) UILabel * addressLabel;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UIImageView * bozhuImageView;

@end

@implementation DTiePostCollectionViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self createDtiePostCell];
        
    }
    return self;
}

- (void)createDtiePostCell
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.baseView];
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.right.mas_equalTo(-30 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo((kMainBoundsWidth - 360 * scale) / 4.f * 3.f);
    }];
    self.baseView.layer.cornerRadius = 24 * scale;
    self.baseView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    self.baseView.layer.shadowOpacity = .3f;
    self.baseView.layer.shadowRadius = 12 * scale;
    self.baseView.layer.shadowOffset = CGSizeMake(0, 6 * scale);
    
    UIView * baseCornerView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.baseView addSubview:baseCornerView];
    baseCornerView.layer.cornerRadius = 24 * scale;
    baseCornerView.layer.masksToBounds = YES;
    [baseCornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.postImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [baseCornerView addSubview:self.postImageView];
    [self.postImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-144 * scale);
    }];
    
    UIView * postNameView = [[UIView alloc] initWithFrame:CGRectZero];
    postNameView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    [self.postImageView addSubview:postNameView];
    [postNameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(90 * scale);
    }];
    
    self.postNameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentLeft];
    [postNameView addSubview:self.postNameLabel];
    [self.postNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    
    UIView * infoView = [[UIView alloc] initWithFrame:CGRectZero];
    infoView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [baseCornerView addSubview:infoView];
    [infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.postImageView.mas_bottom);
        make.left.bottom.right.mas_equalTo(0);
        
    }];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [infoView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-300 * scale);
    }];
    
    self.addressLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [infoView addSubview:self.addressLabel];
    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(5 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(self.timeLabel);
    }];
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [infoView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.timeLabel.mas_right).offset(40 * scale);
        make.top.mas_equalTo(15 * scale);
        make.width.height.mas_equalTo(80 * scale);
    }];
    [DDViewFactoryTool cornerRadius:40 * scale withView:self.logoImageView];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [infoView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(20 * scale);
        make.centerY.mas_equalTo(self.logoImageView);
        make.right.mas_equalTo(-40 * scale);
    }];
    
    self.bozhuImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.bozhuImageView setImage:[UIImage imageNamed:@"bozhuTag"]];
    [infoView addSubview:self.bozhuImageView];
    [self.bozhuImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.logoImageView.mas_bottom).offset(-15 * scale);
        make.width.mas_equalTo(120 * scale);
        make.height.mas_equalTo(34 * scale);
        make.centerX.mas_equalTo(self.logoImageView);
    }];
}

- (void)configWithModel:(DTieEditModel *)model Dtie:(DTieModel *)dtieModel
{
    [self.postImageView sd_setImageWithURL:[NSURL URLWithString:model.postFirstPicture]];
    self.postNameLabel.text = model.postSummary;
    self.timeLabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:model.updateTime];
    self.addressLabel.text = model.sceneAddress;
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
    self.nameLabel.text = model.nickname;
    if (model.bloggerFlg == 1) {
        self.bozhuImageView.hidden = NO;
    }else{
        self.bozhuImageView.hidden = YES;
    }
}

@end
