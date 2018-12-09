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
#import "UIView+LayerCurve.h"

@interface DTieDetailTextTableViewCell ()

@property (nonatomic, strong) DTieModel * dtieModel;
@property (nonatomic, strong) DTieEditModel * model;

@property (nonatomic, strong) UILabel * detailLabel;

@property (nonatomic, strong) UIVisualEffectView * effectView;
@property (nonatomic, strong) UIView * coverView;

@property (nonatomic, strong) UIView * baseView;

@property (nonatomic, assign) BOOL isInstallWX;

@property (nonatomic, strong) UILabel * deedaoLabel;

@property (nonatomic, strong) UIView * authorView;
@property (nonatomic, strong) UIImageView * deedaoImageView;
@property (nonatomic, strong) UIImageView * shareImageView;
@property (nonatomic, strong) UIView * baseCornerView;

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
    
    self.authorView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.authorView layerDotteLinePoints:@[[NSValue valueWithCGPoint:CGPointMake(60 * scale, 2 * scale)], [NSValue valueWithCGPoint:CGPointMake(kMainBoundsWidth - 180 * scale, 2 * scale)]] Color:UIColorFromRGB(0x999999) Width:3 * scale SolidLength:10 * scale DotteLength:10 * scale];
    [self.baseView addSubview:self.authorView];
    [self.authorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.detailLabel.mas_bottom).offset(60 * scale);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    UIButton * deedaoButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0x333333) title:@""];
    [self.authorView addSubview:deedaoButton];
    [deedaoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(180 * scale);
        make.top.mas_equalTo(20 * scale);
        make.width.mas_equalTo(240 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    
    self.deedaoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"chooseno"]];
    [deedaoButton addSubview:self.deedaoImageView];
    [self.deedaoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.width.height.mas_equalTo(60 * scale);
    }];
    
    UILabel * deedaoLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    deedaoLabel.text = @"到地体验";
    [deedaoButton addSubview:deedaoLabel];
    [deedaoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(self.deedaoImageView.mas_right).offset(5 * scale);
        make.height.mas_equalTo(60 * scale);
    }];
    
    UIButton * shareButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0x333333) title:@""];
    [self.authorView addSubview:shareButton];
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(-180 * scale);
        make.top.mas_equalTo(20 * scale);
        make.width.mas_equalTo(240 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    
    self.shareImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"chooseno"]];
    [shareButton addSubview:self.shareImageView];
    [self.shareImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.width.height.mas_equalTo(60 * scale);
    }];
    
    UILabel * shareLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    shareLabel.text = @"微信通行";
    [shareButton addSubview:shareLabel];
    [shareLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(self.shareImageView.mas_right).offset(5 * scale);
        make.height.mas_equalTo(60 * scale);
    }];
    
    UIView * authorHandleView = [[UIView alloc] initWithFrame:CGRectZero];
    authorHandleView.backgroundColor = UIColorFromRGB(0xf5f5f5);
    [self.authorView addSubview:authorHandleView];
    [authorHandleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(144 * scale);
    }];
    
    UIButton * upButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [upButton setImage:[UIImage imageNamed:@"readUp"] forState:UIControlStateNormal];
    [authorHandleView addSubview:upButton];
    [upButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(60 * scale);
        make.width.height.mas_equalTo(80 * scale);
    }];
    
    UIButton * downButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [downButton setImage:[UIImage imageNamed:@"readDown"] forState:UIControlStateNormal];
    [authorHandleView addSubview:downButton];
    [downButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-60 * scale);
        make.width.height.mas_equalTo(80 * scale);
    }];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0xDB6283);
    [authorHandleView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.mas_equalTo(2 * scale);
        make.height.mas_equalTo(40 * scale);
    }];
    
    UIButton * deleteButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"删除模块"];
    [authorHandleView addSubview:deleteButton];
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(120 * scale);
        make.right.mas_equalTo(lineView.mas_left).offset(-80 * scale);
    }];
    
    UIButton * editButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"编辑修改"];
    [authorHandleView addSubview:editButton];
    [editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(120 * scale);
        make.left.mas_equalTo(lineView.mas_right).offset(80 * scale);
    }];
    
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addButton setImage:[UIImage imageNamed:@"addEdit"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.addButton];
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.baseView.mas_bottom).offset(60 * scale);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(72 * scale);
    }];
    
    [self.addButton addTarget:self action:@selector(addButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [deedaoButton addTarget:self action:@selector(deedaoButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [shareButton addTarget:self action:@selector(shareButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [upButton addTarget:self action:@selector(upButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [downButton addTarget:self action:@selector(downButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [deleteButton addTarget:self action:@selector(deleteButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [editButton addTarget:self action:@selector(editButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addButtonDidClicked
{
    if (self.addButtonHandle) {
        self.addButtonHandle();
    }
}

- (void)deedaoButtonDidClicked
{
    if (self.model.pFlag == 1) {
        self.model.pFlag = 0;
        [self.deedaoImageView setImage:[UIImage imageNamed:@"chooseno"]];
    }else{
        self.model.pFlag = 1;
        [self.deedaoImageView setImage:[UIImage imageNamed:@"chooseyes"]];
    }
    
    if (self.shouldUpdateHandle) {
        self.shouldUpdateHandle();
    }
}

- (void)shareButtonDidClicked
{
    if (self.model.shareEnable == 1) {
        self.model.shareEnable = 0;
        self.model.wxCanSee = 0;
        [self.shareImageView setImage:[UIImage imageNamed:@"chooseno"]];
    }else{
        self.model.shareEnable = 1;
        self.model.wxCanSee = 1;
        [self.shareImageView setImage:[UIImage imageNamed:@"chooseyes"]];
    }
    
    if (self.shouldUpdateHandle) {
        self.shouldUpdateHandle();
    }
}

- (void)upButtonDidClicked
{
    if (self.upButtonHandle) {
        self.upButtonHandle();
    }
}

- (void)downButtonDidClicked
{
    if (self.downButtonHandle) {
        self.downButtonHandle();
    }
}

- (void)deleteButtonDidClicked
{
    if (self.deleteButtonHandle) {
        self.deleteButtonHandle();
    }
}

- (void)editButtonDidClicked
{
    if (self.editButtonHandle) {
        self.editButtonHandle();
    }
}

- (void)configWithModel:(DTieEditModel *)model Dtie:(DTieModel *)dtieModel
{
    self.model = model;
    self.dtieModel = dtieModel;
    
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
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    if ([UserManager shareManager].user.cid == dtieModel.authorId) {
        self.authorView.hidden = NO;
        self.addButton.hidden = NO;
        [self.detailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-360 * scale);
        }];
        [self.baseView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-45 * scale - 120 * scale);
        }];
        
        if (self.model.shareEnable == 1) {
            [self.shareImageView setImage:[UIImage imageNamed:@"chooseyes"]];
        }else{
            [self.shareImageView setImage:[UIImage imageNamed:@"chooseno"]];
        }
        
        if (self.model.pFlag == 1) {
            [self.deedaoImageView setImage:[UIImage imageNamed:@"chooseyes"]];
        }else{
            [self.deedaoImageView setImage:[UIImage imageNamed:@"chooseno"]];
        }
    }else{
        self.authorView.hidden = YES;
        self.addButton.hidden = YES;
        [self.detailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-60 * scale);
        }];
        [self.baseView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-45 * scale);
        }];
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
