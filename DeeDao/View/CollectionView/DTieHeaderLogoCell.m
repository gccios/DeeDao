//
//  DTieHeaderLogoCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieHeaderLogoCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import "UserManager.h"

@interface DTieHeaderLogoCell ()

@property (nonatomic, strong) UIImageView * logoImageView;

@property (nonatomic, strong) UIImageView * BGImageView;

@property (nonatomic, strong) UILabel * DTieTitleLabel;

@property (nonatomic, strong) UIImageView * markImageView;

@property (nonatomic, strong) UIButton * editButton;

@property (nonatomic, strong) UILabel * editLabel;

@property (nonatomic, strong) UIView * titleView;

@property (nonatomic, strong) UIButton * deleteButton;

@end

@implementation DTieHeaderLogoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createDtieCollectionCell];
    }
    return self;
}

- (void)createDtieCollectionCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    self.BGImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"DTieBG"]];
    self.BGImageView.userInteractionEnabled = YES;
    [self.contentView addSubview:self.BGImageView];
    [self.BGImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(60 * scale);
        make.left.mas_equalTo(60 * scale);
        make.bottom.mas_equalTo(0 * scale);
        make.right.mas_equalTo(-30 * scale);
    }];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor, (__bridge id)[UIColorFromRGB(0x9B9B9B) colorWithAlphaComponent:.15f].CGColor];
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth / 2 + 1, 20 * scale);
    
    self.coverView = [[UIView alloc] initWithFrame:CGRectZero];
    self.coverView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.contentView addSubview:self.coverView];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(5);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(50 * scale);
    }];
    [self.coverView.layer addSublayer:gradientLayer];
    
    self.contenImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    self.contenImageView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.7f];
    self.contentView.userInteractionEnabled = YES;
    [self.BGImageView addSubview:self.contenImageView];
    [self.contenImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15 * scale);
        make.left.mas_equalTo(25 * scale);
        make.bottom.mas_equalTo(-25 * scale);
        make.right.mas_equalTo(-29 * scale);
    }];
    self.contenImageView.layer.cornerRadius = 20 * scale;
    self.contenImageView.layer.masksToBounds = YES;
    
    self.titleView = [[UIView alloc] init];
    self.titleView.backgroundColor = [UIColorFromRGB(0x111111) colorWithAlphaComponent:.7f];
    [self.contenImageView addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(85 * scale);
    }];
    
    self.DTieTitleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentLeft];
    [self.titleView addSubview:self.DTieTitleLabel];
    [self.DTieTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(18 * scale);
        make.left.mas_equalTo(24 * scale);
        make.right.mas_equalTo(-24 * scale);
        make.height.mas_equalTo(40 * scale);
    }];
    
    self.markImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"DTieCollection"]];
    [self.contentView addSubview:self.markImageView];
    [self.markImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(30 * scale);
        make.width.mas_equalTo(60 * scale);
        make.height.mas_equalTo(348 * scale);
        make.right.mas_equalTo(self.BGImageView.mas_right).offset(-50 * scale);
    }];
    
    self.editButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColorFromRGB(0x111111) colorWithAlphaComponent:.7f] title:@""];
    [self.editButton setImageEdgeInsets:UIEdgeInsetsMake(-30 * scale, 0, 0, 0)];
    [self.editButton setImage:[UIImage imageNamed:@"DTieEdit"] forState:UIControlStateNormal];
    [self.contenImageView addSubview:self.editButton];
    [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(0);
    }];
    
    self.editLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentLeft];
    [self.editButton addSubview:self.editLabel];
    [self.editLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(28 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(40 * scale);
        make.bottom.mas_equalTo(-30 * scale);
    }];
    
    self.deleteButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(40 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [self.deleteButton setImage:[UIImage imageNamed:@"jianqubig"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.deleteButton];
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(40 * scale);
        make.right.mas_equalTo(self.contenImageView).offset(25 * scale);
        make.width.height.mas_equalTo(70 * scale);
    }];
    [self.deleteButton addTarget:self action:@selector(cancleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    self.deleteButton.hidden = YES;
    
    UIView * logoBGView = [[UIView alloc] initWithFrame:CGRectZero];
    logoBGView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:logoBGView];
    [logoBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.BGImageView.mas_left).offset(-20 * scale);
        make.top.mas_equalTo(30 * scale);
        make.width.height.mas_equalTo(96 * scale);
    }];
    logoBGView.layer.cornerRadius = 48 * scale;
    logoBGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    logoBGView.layer.shadowOpacity = .5f;
    logoBGView.layer.shadowRadius = 8 * scale;
    logoBGView.layer.shadowOffset = CGSizeMake(0, 4 * scale);
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [self.contentView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.BGImageView.mas_left).offset(-20 * scale);
        make.top.mas_equalTo(30 * scale);
        make.width.height.mas_equalTo(96 * scale);
    }];
    [DDViewFactoryTool cornerRadius:48 * scale withView:self.logoImageView];
}

- (void)cancleButtonDidClicked
{
    if (self.deleteButton) {
        self.deleteButtonHandle();
    }
}

- (void)setIndexPath:(NSIndexPath *)indexPath
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    if (indexPath.item % 2 == 1) {
        [self.BGImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(30 * scale);
            make.right.mas_equalTo(-60 * scale);
        }];
        
    }else{
        [self.BGImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(60 * scale);
            make.right.mas_equalTo(-30 * scale);
        }];
    }
    
    _indexPath = indexPath;
}

- (void)configWithDTieModel:(DTieModel *)model
{
    if (isEmptyString(model.postSummary)) {
        if (isEmptyString(model.sceneBuilding)) {
            self.DTieTitleLabel.text = @"";
        }else{
            self.DTieTitleLabel.text = model.sceneBuilding;
        }
    }else{
        self.DTieTitleLabel.text = model.postSummary;
    }
    
    NSURL * imageURL = [NSURL URLWithString:model.postFirstPicture];
    if (isEmptyString(imageURL)) {
        [self.contenImageView setImage:[UIImage imageNamed:@"defaultRemark.jpg"]];
    }else{
        [self.contenImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"list_bg"]];
    }
    
    if (model.status == 0 && [UserManager shareManager].user.cid == model.authorId ) {
        self.editButton.hidden = YES;
        self.markImageView.hidden = YES;
        self.titleView.hidden = YES;
        self.editLabel.text = self.DTieTitleLabel.text;
    }else if (model.collectFlg == 1) {
        self.editButton.hidden = YES;
        [self.markImageView setImage:[UIImage imageNamed:@"DTieCollection"]];
        self.markImageView.hidden = NO;
        self.titleView.hidden = NO;
    }else if (model.wyyFlg == 1) {
        self.editButton.hidden = YES;
        [self.markImageView setImage:[UIImage imageNamed:@"DTieBeFoundTo"]];
        self.markImageView.hidden = NO;
        self.titleView.hidden = NO;
    }else{
        self.editButton.hidden = YES;
        self.markImageView.hidden = YES;
        self.titleView.hidden = NO;
    }
    
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
}

- (void)confiEditEnable:(BOOL)edit
{
    if (edit) {
        self.deleteButton.hidden = NO;
    }else{
        self.deleteButton.hidden = YES;
    }
}

@end
