//
//  DTieDetailImageTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/17.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieDetailImageTableViewCell.h"
#import "DDTool.h"
#import <UIImageView+WebCache.h>
#import <Masonry.h>
#import "DDShareManager.h"
#import "LookImageViewController.h"
#import "DDLocationManager.h"
#import "UserManager.h"
#import <WXApi.h>
#import "DDLGSideViewController.h"
#import "DDBackWidow.h"

@interface DTieDetailImageTableViewCell ()

@property (nonatomic, strong) UIImageView * detailImageView;
@property (nonatomic, strong) DTieModel * dtieModel;
@property (nonatomic, strong) DTieEditModel * model;

@property (nonatomic, strong) UIImageView * quanxianImageView;

@property (nonatomic, strong) UIVisualEffectView * effectView;
@property (nonatomic, strong) UIView * converView;

@property (nonatomic, strong) UIView * baseView;

@property (nonatomic, assign) BOOL isInstallWX;

@property (nonatomic, strong) UILabel * deedaoLabel;

@end

@implementation DTieDetailImageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.isInstallWX = [WXApi isWXAppInstalled];
        [self createDetailImageCell];
    }
    return self;
}

- (void)createDetailImageCell
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.baseView];
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(45 * scale);
        make.left.mas_equalTo(60 * scale);
        make.bottom.mas_equalTo(-45 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    self.baseView.layer.cornerRadius = 24 * scale;
    self.baseView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    self.baseView.layer.shadowOpacity = .3f;
    self.baseView.layer.shadowRadius = 24 * scale;
    self.baseView.layer.shadowOffset = CGSizeMake(0, 12 * scale);
    
    UIView * baseCornerView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.baseView addSubview:baseCornerView];
    baseCornerView.layer.cornerRadius = 24 * scale;
    baseCornerView.layer.masksToBounds = YES;
    [baseCornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.detailImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.detailImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.detailImageView.clipsToBounds = YES;
    [baseCornerView addSubview:self.detailImageView];
    [self.detailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDidHandle:)];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidTap:)];
    self.detailImageView.userInteractionEnabled = YES;
    [self.detailImageView addGestureRecognizer:longPress];
    [self.detailImageView addGestureRecognizer:tap];
    
    self.converView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.detailImageView addSubview:self.converView];
    [self.converView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.converView.hidden = YES;
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    self.effectView.alpha = .98f;
    [self.converView addSubview:self.effectView];
    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    UIImageView * deedaoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    deedaoImageView.contentMode = UIViewContentModeScaleAspectFill;
    [deedaoImageView setImage:[UIImage imageNamed:@"Dtie"]];
    [self.converView addSubview:deedaoImageView];
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
    [self.converView addSubview:self.deedaoLabel];
    [self.deedaoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(70 * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(60 * scale);
    }];
    
    self.quanxianImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.quanxianImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.quanxianImageView setImage:[UIImage imageNamed:@"zuozhewx"]];
    [baseCornerView addSubview:self.quanxianImageView];
    [self.quanxianImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.detailImageView.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(72 * scale);
    }];
    self.quanxianImageView.hidden = YES;
}

- (void)imageDidTap:(UITapGestureRecognizer *)tap
{
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    if (self.model.image) {
        LookImageViewController * look = [[LookImageViewController alloc] initWithImage:self.model.image];
        [na presentViewController:look animated:NO completion:nil];
        [[DDBackWidow shareWindow] hidden];
    }else{
        LookImageViewController * look = [[LookImageViewController alloc] initWithImageURL:self.model.detailContent];
        [na presentViewController:look animated:NO completion:nil];
        [[DDBackWidow shareWindow] hidden];
    }
}

//- (void)configWithCanSee:(BOOL)cansee
//{
//
//}

- (void)longPressDidHandle:(UILongPressGestureRecognizer *)longPress
{
    ShareImageModel * model = [[ShareImageModel alloc] init];
    NSInteger postId = self.dtieModel.cid;
    if (postId == 0) {
        postId = self.dtieModel.postId;
    }
    model.postId = postId;
    model.image = self.detailImageView.image;
    model.title = self.dtieModel.postSummary;
    model.PFlag = self.model.pFlag;
    if (model.PFlag == 1) {
        [model changeToDeedao];
    }
    
    [[DDShareManager shareManager] showHandleViewWithImage:model];
}

//- (void)configWithModel:(DTieEditModel *)model
//{
//    self.model = model;
//    
//    if (model.image) {
//        [self.detailImageView setImage:model.image];
//    }else{
//        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:model.detailContent];
//        
//        if (image) {
//            [self.detailImageView setImage:image];
//        }else{
//            [self.detailImageView setImage:[UIImage new]];
//        }
//    }
//}

- (void)configWithModel:(DTieEditModel *)model Dtie:(DTieModel *)dtieModel
{
    self.model = model;
    self.dtieModel = dtieModel;
    
    [self.detailImageView sd_cancelCurrentAnimationImagesLoad];
    
    if (model.image) {
        [self.detailImageView setImage:model.image];
    }else{
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:model.detailContent];
        
        if (image) {
            [self.detailImageView setImage:image];
        }else{
            [self.detailImageView setImage:[UIImage new]];
        }
    }
    
    if (model.pFlag == 1) {
        
        if ([[DDLocationManager shareManager] contentIsCanSeeWith:dtieModel detailModle:model]) {
            if (model.wxCanSee == 1) {
                self.detailImageView.userInteractionEnabled = YES;
                self.converView.hidden = YES;
            }else{
                if (dtieModel.ifCanSee == 0) {
                    self.deedaoLabel.text = @"暂无浏览权限";
                    self.detailImageView.userInteractionEnabled = NO;
                    self.converView.hidden = NO;
                }else{
                    self.detailImageView.userInteractionEnabled = YES;
                    self.converView.hidden = YES;
                }
            }
        }else{
            
            if (dtieModel.ifCanSee == 0) {
                if (model.wxCanSee == 1) {
                    self.deedaoLabel.text = @"到地体验";
                    self.detailImageView.userInteractionEnabled = YES;
                    self.converView.hidden = NO;
                }else{
                    self.deedaoLabel.text = @"暂无浏览权限";
                    self.detailImageView.userInteractionEnabled = NO;
                    self.converView.hidden = NO;
                }
            }else{
                self.deedaoLabel.text = @"到地体验";
                self.detailImageView.userInteractionEnabled = YES;
                self.converView.hidden = NO;
            }
            
        }
        
    }else{
        
        if (model.wxCanSee == 1) {
            
            self.detailImageView.userInteractionEnabled = YES;
            self.converView.hidden = YES;
            
        }else {
            if (dtieModel.ifCanSee == 0) {
                self.deedaoLabel.text = @"暂无浏览权限";
                self.detailImageView.userInteractionEnabled = NO;
                self.converView.hidden = NO;
            }else{
                self.detailImageView.userInteractionEnabled = YES;
                if ([[DDLocationManager shareManager] contentIsCanSeeWith:dtieModel detailModle:model]) {
                    self.detailImageView.userInteractionEnabled = YES;
                    self.converView.hidden = YES;
                }else{
                    self.deedaoLabel.text = @"到地体验";
                    self.detailImageView.userInteractionEnabled = YES;
                    self.converView.hidden = NO;
                }
            }
        }
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
            imageName = @"zuozhedd";
        }
        
        if (isEmptyString(imageName)) {
            [self.detailImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(0 * scale);
            }];
            self.quanxianImageView.hidden = YES;
        }else{
            [self.detailImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-72 * scale);
            }];
            [self.quanxianImageView setImage:[UIImage imageNamed:imageName]];
            self.quanxianImageView.hidden = NO;
        }
    }
}

//- (void)yulanWithModel:(DTieEditModel *)model
//{
//    if (model.image) {
//        [self.detailImageView setImage:model.image];
//    }else{
//        [self.detailImageView setImage:[UIImage imageNamed:@"hengBG"]];
//    }
//}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
