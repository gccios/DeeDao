//
//  MineHeaderView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/10.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "MineHeaderView.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import "UserManager.h"
#import <UIImageView+WebCache.h>
#import <BGUtilFunction.h>

@interface MineHeaderView ()

@property (nonatomic, strong) UIImageView * headerImageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * IDLabel;
@property (nonatomic, strong) UIImageView * QRCodeImageView;

@end

@implementation MineHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createMineHeaderView];
    }
    return self;
}

- (void)createMineHeaderView
{
    self.backgroundColor = [UIColor whiteColor];
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIImageView * headerBGView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"headerBG"]];
    [self addSubview:headerBGView];
    [headerBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(176 * scale);
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(44 * scale);
    }];
    
    self.headerImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [self addSubview:self.headerImageView];
    [self.headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(144 * scale);
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(60 * scale);
    }];
    self.headerImageView.layer.cornerRadius = 144 * scale / 2;
    self.headerImageView.layer.masksToBounds = YES;
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[UserManager shareManager].user.portraituri]];
    
    if ([UserManager shareManager].user.bloggerFlg == 1) {
        UIImageView * bozhuImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [bozhuImageView setImage:[UIImage imageNamed:@"bozhuTag"]];
        [self addSubview:bozhuImageView];
        [bozhuImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.headerImageView.mas_bottom).offset(-15 * scale);
            make.width.mas_equalTo(150 * scale);
            make.height.mas_equalTo(42 * scale);
            make.centerX.mas_equalTo(self.headerImageView);
        }];
    }
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(54 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    self.nameLabel.text = [UserManager shareManager].user.nickname;
    [self addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(-40 * scale);
        make.left.mas_equalTo(self.headerImageView.mas_right).offset(48 * scale);
        make.height.mas_equalTo(60 * scale);
    }];
    
    self.IDLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    NSString * userID = [NSString stringWithFormat:@"%ld", [UserManager shareManager].user.cid];
    NSString * md5 = BG_MD5(userID);
    if (md5.length > 8) {
        md5 = [md5 substringToIndex:8];
    }
    self.IDLabel.text = [NSString stringWithFormat:@"Dee Dao ID:%@%@", md5, userID];
    [self addSubview:self.IDLabel];
    [self.IDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(15 * scale);
        make.left.mas_equalTo(self.headerImageView.mas_right).offset(48 * scale);
        make.height.mas_equalTo(58 * scale);
    }];
    
//    self.QRCodeImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFit image:[UIImage imageNamed:@"test"]];
//    [self addSubview:self.QRCodeImageView];
//    [self.QRCodeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.height.mas_equalTo(72 * scale);
//        make.centerY.mas_equalTo(0);
//        make.right.mas_equalTo(-60 * scale);
//    }];
}

@end
