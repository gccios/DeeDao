//
//  DTieDetailVideoTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/17.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieDetailVideoTableViewCell.h"
#import "DDTool.h"
#import <UIImageView+WebCache.h>
#import <Masonry.h>
#import <AVKit/AVKit.h>
#import "DDLocationManager.h"
#import "UserManager.h"
#import <WXApi.h>
#import "DDLGSideViewController.h"
#import "DDBackWidow.h"
#import "DDViewFactoryTool.h"

@interface DTieDetailVideoTableViewCell ()

@property (nonatomic, strong) UIImageView * detailImageView;
@property (nonatomic, strong) UIImageView * playImageView;;
@property (nonatomic, strong) DTieEditModel * model;

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

@implementation DTieDetailVideoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.isInstallWX = [WXApi isWXAppInstalled];
        [self createDetailVideoCell];
    }
    return self;
}

- (void)createDetailVideoCell
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
    
    self.baseCornerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.baseCornerView.backgroundColor = UIColorFromRGB(0xefeff4);
    [self.baseView addSubview:self.baseCornerView];
    self.baseCornerView.layer.cornerRadius = 24 * scale;
    self.baseCornerView.layer.masksToBounds = YES;
    [self.baseCornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.detailImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.detailImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.detailImageView.clipsToBounds = YES;
    [self.baseCornerView addSubview:self.detailImageView];
    [self.detailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidTap:)];
    self.detailImageView.userInteractionEnabled = YES;
    [self.detailImageView addGestureRecognizer:tap];
    
    self.playImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.playImageView setImage:[UIImage imageNamed:@"player"]];
    [self.detailImageView addSubview:self.playImageView];
    [self.playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo(150 * scale);
    }];
    
    self.coverView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.detailImageView addSubview:self.coverView];
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
    [self.baseCornerView addSubview:self.authorView];
    [self.authorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.detailImageView.mas_bottom).offset(0);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    UIButton * deedaoButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0x333333) title:@""];
    [self.authorView addSubview:deedaoButton];
    [deedaoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0 * scale);
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
    
    shareButton.hidden = YES;
    
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
    
//    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
//    lineView.backgroundColor = UIColorFromRGB(0xDB6283);
//    [authorHandleView addSubview:lineView];
//    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.mas_equalTo(0);
//        make.width.mas_equalTo(2 * scale);
//        make.height.mas_equalTo(40 * scale);
//    }];
    
    UIButton * deleteButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"删除模块"];
    [authorHandleView addSubview:deleteButton];
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(120 * scale);
        make.width.mas_equalTo(360);
    }];
    
//    UIButton * editButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"编辑修改"];
//    [authorHandleView addSubview:editButton];
//    [editButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(0);
//        make.height.mas_equalTo(120 * scale);
//        make.left.mas_equalTo(lineView.mas_right).offset(80 * scale);
//    }];
//
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
//    [editButton addTarget:self action:@selector(editButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
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

- (void)imageDidTap:(UITapGestureRecognizer *)tap
{
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    
    if (self.model.asset) {
        
        //配置导出参数
        PHVideoRequestOptions *options = [PHVideoRequestOptions new];
        options.networkAccessAllowed = YES;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        
        //通过PHAsset获取AVAsset对象
        [[PHImageManager defaultManager] requestAVAssetForVideo:self.model.asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            AVPlayerViewController * player = [[AVPlayerViewController alloc] init];
            player.player = [[AVPlayer alloc] initWithPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
            player.videoGravity = AVLayerVideoGravityResizeAspect;
            [na presentViewController:player animated:YES completion:nil];
            [[DDBackWidow shareWindow] hidden];
        }];
        
    }else{
        
        NSURL * url;
        if (self.model.videoURL) {
            url = self.model.videoURL;
        }else{
            url = [NSURL URLWithString:self.model.textInformation];
        }
        
        AVPlayerViewController * player = [[AVPlayerViewController alloc] init];
        player.player = [[AVPlayer alloc] initWithURL:url];
        player.videoGravity = AVLayerVideoGravityResizeAspect;
        [na presentViewController:player animated:YES completion:nil];
        [[DDBackWidow shareWindow] hidden];
    }
}

//- (void)configWithCanSee:(BOOL)cansee
//{
//
//}
//
//- (void)configWithModel:(DTieEditModel *)model
//{
//    self.model = model;
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
    if (model.image) {
        [self.detailImageView setImage:model.image];
    }else{
        
        [self.detailImageView sd_setImageWithURL:[NSURL URLWithString:model.detailContent] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            model.image = image;
        }];
    }
    
    if (model.pFlag == 1) {
        
        if ([[DDLocationManager shareManager] contentIsCanSeeWith:dtieModel detailModle:model]) {
            if (model.wxCanSee == 1) {
                self.detailImageView.userInteractionEnabled = YES;
                self.coverView.hidden = YES;
            }else{
                if (dtieModel.ifCanSee == 0) {
                    self.deedaoLabel.text = @"暂无浏览权限";
                    self.detailImageView.userInteractionEnabled = NO;
                    self.coverView.hidden = NO;
                }else{
                    self.detailImageView.userInteractionEnabled = YES;
                    self.coverView.hidden = YES;
                }
            }
        }else{
            
            if (dtieModel.ifCanSee == 0) {
                if (model.wxCanSee == 1) {
                    self.deedaoLabel.text = @"到地体验";
                    self.detailImageView.userInteractionEnabled = YES;
                    self.coverView.hidden = NO;
                }else{
                    self.deedaoLabel.text = @"暂无浏览权限";
                    self.detailImageView.userInteractionEnabled = NO;
                    self.coverView.hidden = NO;
                }
            }else{
                self.deedaoLabel.text = @"到地体验";
                self.detailImageView.userInteractionEnabled = YES;
                self.coverView.hidden = NO;
            }
            
        }
        
    }else{
        
        if (model.wxCanSee == 1) {
            
            self.detailImageView.userInteractionEnabled = YES;
            self.coverView.hidden = YES;
            
        }else {
            if (dtieModel.ifCanSee == 0) {
                self.deedaoLabel.text = @"暂无浏览权限";
                self.detailImageView.userInteractionEnabled = NO;
                self.coverView.hidden = NO;
            }else{
                self.detailImageView.userInteractionEnabled = YES;
                if ([[DDLocationManager shareManager] contentIsCanSeeWith:dtieModel detailModle:model]) {
                    self.detailImageView.userInteractionEnabled = YES;
                    self.coverView.hidden = YES;
                }else{
                    self.deedaoLabel.text = @"到地体验";
                    self.detailImageView.userInteractionEnabled = YES;
                    self.coverView.hidden = NO;
                }
            }
        }
    }
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    if ([UserManager shareManager].user.cid == dtieModel.authorId) {
        self.authorView.hidden = NO;
        self.addButton.hidden = NO;
        [self.detailImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-300 * scale);
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
        [self.detailImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
        }];
        [self.baseView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-45 * scale);
        }];
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
