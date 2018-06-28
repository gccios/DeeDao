//
//  DTieDetailTextTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/17.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieDetailTextTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import "DDLocationManager.h"
#import "UserManager.h"
#import <WXApi.h>

@interface DTieDetailTextTableViewCell ()

@property (nonatomic, strong) UILabel * detailLabel;

@property (nonatomic, strong) UIImageView * quanxianImageView;
@property (nonatomic, strong) UIVisualEffectView * effectView;
@property (nonatomic, strong) UIView * coverView;

@property (nonatomic, strong) UIView * baseView;

@property (nonatomic, assign) BOOL isInstallWX;

@end

@implementation DTieDetailTextTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.isInstallWX = [WXApi isWXAppInstalled];
        [self createDetailTextCell];
    }
    return self;
}

- (void)createDetailTextCell
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIView * baseCornerView = [[UIView alloc] initWithFrame:CGRectZero];
    baseCornerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:baseCornerView];
    [baseCornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(45 * scale);
        make.left.mas_equalTo(60 * scale);
        make.bottom.mas_equalTo(-45 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    baseCornerView.layer.cornerRadius = 24 * scale;
    baseCornerView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    baseCornerView.layer.shadowOpacity = .3f;
    baseCornerView.layer.shadowRadius = 24 * scale;
    baseCornerView.layer.shadowOffset = CGSizeMake(0, 12 * scale);
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectZero];
    self.baseView.backgroundColor = [UIColorFromRGB(0xDB6283) colorWithAlphaComponent:.1f];
    [self.contentView addSubview:self.baseView];
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(45 * scale);
        make.left.mas_equalTo(60 * scale);
        make.bottom.mas_equalTo(-45 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    self.baseView.layer.cornerRadius = 24 * scale;
    self.baseView.layer.masksToBounds = YES;
    
    self.detailLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.detailLabel.numberOfLines = 0;
    [self.baseView addSubview:self.detailLabel];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(60 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.bottom.mas_equalTo(-60 * scale);
    }];
    
    self.coverView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.baseView addSubview:self.coverView];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
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
    
    UILabel * deedaoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    deedaoLabel.textAlignment = NSTextAlignmentCenter;
    deedaoLabel.font = kPingFangMedium(42 * scale);
    deedaoLabel.text = @"到 地 体 验";
    deedaoLabel.textColor = UIColorFromRGB(0xFFFFFF);
    [self.coverView addSubview:deedaoLabel];
    [deedaoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(70 * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(60 * scale);
    }];
    
    self.quanxianImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.quanxianImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.quanxianImageView setImage:[UIImage imageNamed:@"zuozhewx"]];
    [self.baseView addSubview:self.quanxianImageView];
    [self.quanxianImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(72 * scale);
    }];
    self.quanxianImageView.hidden = YES;
}

//- (void)configWithCanSee:(BOOL)cansee
//{
//    
//}
//
//- (void)configWithModel:(DTieEditModel *)model
//{
//    NSString * text = model.detailContent;
//    
//    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
//    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
//    paraStyle.alignment = NSTextAlignmentLeft;
//    paraStyle.lineSpacing = 6; //设置行间距
//    paraStyle.hyphenationFactor = 1.0;
//    paraStyle.firstLineHeadIndent = 0.0;
//    paraStyle.paragraphSpacingBefore = 0.0;
//    paraStyle.headIndent = 0;
//    paraStyle.tailIndent = 0;
//    //设置字间距 NSKernAttributeName:@1.5f
//    NSDictionary *dic = @{NSFontAttributeName:self.detailLabel.font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@1.5f
//                          };
//    
//    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:text attributes:dic];
//    
//    self.detailLabel.attributedText = attributeStr;
//}

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
    
    if ([[DDLocationManager shareManager] contentIsCanSeeWith:dtieModel detailModle:model]) {
        self.coverView.hidden = YES;
    }else{
        self.coverView.hidden = NO;
    }
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    if (dtieModel.authorId == [UserManager shareManager].user.cid) {
        
        if (!self.isInstallWX) {
            self.quanxianImageView.hidden = YES;
            return;
        }
        
        NSString * imageName = @"";
        if (model.wxCanSee == 1 || model.shareEnable == 1) {
            imageName = @"zuozhewx";
            if (model.pFlag == 1) {
                imageName = @"zuozhewxdd";
            }
        }else if (model.pFlag == 1) {
            imageName = @"zuozhetextdd";
        }
        
        if (isEmptyString(imageName)) {
            self.quanxianImageView.hidden = YES;
        }else{
            [self.quanxianImageView setImage:[UIImage imageNamed:imageName]];
            self.quanxianImageView.hidden = NO;
        }
        if (isEmptyString(imageName)) {
            [self.detailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-60 * scale);
            }];
            self.quanxianImageView.hidden = YES;
        }else{
            [self.detailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo((-72-60) * scale);
            }];
            [self.quanxianImageView setImage:[UIImage imageNamed:imageName]];
            self.quanxianImageView.hidden = NO;
        }
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
