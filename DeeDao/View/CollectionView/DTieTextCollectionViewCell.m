//
//  DTieTextCollectionViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/20.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieTextCollectionViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import "DDLocationManager.h"
#import "UserManager.h"
#import "DDTool.h"

@interface DTieTextCollectionViewCell ()

@property (nonatomic, strong) UILabel * detailLabel;

@property (nonatomic, strong) UIVisualEffectView * effectView;
@property (nonatomic, strong) UIView * coverView;
@property (nonatomic, strong) UILabel * deedaoLabel;

@property (nonatomic, strong) UIView * baseCornerView;
@property (nonatomic, strong) UIView * baseView;

@end

@implementation DTieTextCollectionViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createDetailTextCell];
    }
    return self;
}

- (void)createDetailTextCell
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.baseCornerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.baseCornerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.baseCornerView];
    [self.baseCornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.right.mas_equalTo(-30 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(0.1f);
    }];
    self.baseCornerView.layer.cornerRadius = 24 * scale;
    self.baseCornerView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    self.baseCornerView.layer.shadowOpacity = .3f;
    self.baseCornerView.layer.shadowRadius = 12 * scale;
    self.baseCornerView.layer.shadowOffset = CGSizeMake(0, 6 * scale);
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectZero];
    self.baseView.backgroundColor = [UIColorFromRGB(0xDB6283) colorWithAlphaComponent:.1f];
    [self.contentView addSubview:self.baseView];
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.right.mas_equalTo(-30 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(0.1f);
    }];
    self.baseView.layer.cornerRadius = 24 * scale;
    self.baseView.layer.masksToBounds = YES;
    
    self.detailLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.detailLabel.numberOfLines = 0;
    [self.baseView addSubview:self.detailLabel];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(40 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.bottom.mas_equalTo(-40 * scale);
    }];
    
    self.coverView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.baseView addSubview:self.coverView];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.left.right.height.mas_equalTo(self.baseCornerView);
    }];
    self.coverView.hidden = YES;
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    self.effectView.alpha = .98f;
    [self.coverView addSubview:self.effectView];
    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    UIImageView * deedaoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    deedaoImageView.contentMode = UIViewContentModeScaleAspectFill;
    [deedaoImageView setImage:[UIImage imageNamed:@"Dtie"]];
    [self.coverView addSubview:deedaoImageView];
    [deedaoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(-30 * scale);
        make.width.height.mas_equalTo(150 * scale);
    }];
    
    self.deedaoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.deedaoLabel.textAlignment = NSTextAlignmentCenter;
    self.deedaoLabel.font = kPingFangMedium(42 * scale);
    self.deedaoLabel.text = @"到 地 体 验";
    self.deedaoLabel.textColor = UIColorFromRGB(0xFFFFFF);
    [self.coverView addSubview:self.deedaoLabel];
    [self.deedaoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(70 * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(60 * scale);
    }];
}

- (void)configWithModel:(DTieEditModel *)model Dtie:(DTieModel *)dtieModel
{
    NSString * text = model.detailContent;
    if (isEmptyString(text)) {
        text = model.detailsContent;
    }
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = 6; //设置行间距
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    //设置字间距 NSKernAttributeName:@1.5f
    NSDictionary *dic = @{NSFontAttributeName:self.detailLabel.font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@1.5f
                          };
    
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:text attributes:dic];
    
    self.detailLabel.attributedText = attributeStr;
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    CGFloat height = [DDTool getHeightByWidth:kMainBoundsWidth - 360* scale title:model.detailsContent font:kPingFangRegular(42 * scale)] + 140 * scale;
    CGFloat maxHeight = kMainBoundsHeight - (kStatusBarHeight + 824) * scale - 60 * scale;
    if (height > maxHeight) {
        height = maxHeight;
    }
    [self.baseCornerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    [self.baseView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    if (nil == dtieModel) {
        return;
    }
    if (dtieModel.landAccountFlg == 2 && dtieModel.authorId != [UserManager shareManager].user.cid) {
        self.deedaoLabel.text = @"暂无浏览权限";
        self.coverView.hidden = NO;
        return;
    }
    if (model.pFlag == 1) {
        
        if ([[DDLocationManager shareManager] contentIsCanSeeWith:dtieModel detailModle:model]) {
            if (model.wxCanSee == 1) {
                self.coverView.hidden = YES;
            }else{
                if (dtieModel.ifCanSee == 0) {
                    self.deedaoLabel.text = @"暂无浏览权限";
                    self.coverView.hidden = NO;
                }else{
                    self.coverView.hidden = YES;
                }
            }
        }else{
            
            if (dtieModel.ifCanSee == 0) {
                if (model.wxCanSee == 1) {
                    self.deedaoLabel.text = @"到地体验";
                    self.coverView.hidden = NO;
                }else{
                    self.deedaoLabel.text = @"暂无浏览权限";
                    self.coverView.hidden = NO;
                }
            }else{
                self.deedaoLabel.text = @"到地体验";
                self.coverView.hidden = NO;
            }
            
        }
        
    }else{
        
        if (model.wxCanSee == 1) {
            
            self.coverView.hidden = YES;
            
        }else {
            if (dtieModel.ifCanSee == 0) {
                self.deedaoLabel.text = @"暂无浏览权限";
                self.coverView.hidden = NO;
            }else{
                if ([[DDLocationManager shareManager] contentIsCanSeeWith:dtieModel detailModle:model]) {
                    self.coverView.hidden = YES;
                }else{
                    self.deedaoLabel.text = @"到地体验";
                    self.coverView.hidden = NO;
                }
            }
        }
    }
}

@end
