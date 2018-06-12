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

@interface DTieDetailVideoTableViewCell ()

@property (nonatomic, strong) UIImageView * detailImageView;
@property (nonatomic, strong) UIImageView * playImageView;;
@property (nonatomic, strong) DTieEditModel * model;

@property (nonatomic, strong) UIImageView * quanxianImageView;
@property (nonatomic, strong) UIVisualEffectView * effectView;
@property (nonatomic, strong) UIView * coverView;

@end

@implementation DTieDetailVideoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createDetailVideoCell];
    }
    return self;
}

- (void)createDetailVideoCell
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.detailImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.detailImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.detailImageView];
    [self.detailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(24 * scale);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-24 * scale);
    }];
    self.detailImageView.clipsToBounds = YES;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidTap:)];
    self.detailImageView.userInteractionEnabled = YES;
    [self.detailImageView addGestureRecognizer:tap];
    
    self.playImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.playImageView setImage:[UIImage imageNamed:@"player"]];
    [self.contentView addSubview:self.playImageView];
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
    [self.quanxianImageView setImage:[UIImage imageNamed:@"zuozhewx"]];
    [self.contentView addSubview:self.quanxianImageView];
    [self.quanxianImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.detailImageView.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(72 * scale);
    }];
    self.quanxianImageView.hidden = YES;
}

- (void)imageDidTap:(UITapGestureRecognizer *)tap
{
    UITabBarController * tab = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)tab.selectedViewController;
    NSURL * url;
    if (self.model.videoURL) {
        url = self.model.videoURL;
    }else{
        url = [NSURL URLWithString:self.model.textInformation];
    }
    AVPlayerViewController * playView = [[AVPlayerViewController alloc] init];
    playView = [[AVPlayerViewController alloc] init];
    playView.player = [[AVPlayer alloc] initWithURL:url];
    playView.videoGravity = AVLayerVideoGravityResizeAspect;
    [na presentViewController:playView animated:YES completion:nil];
}

- (void)configWithCanSee:(BOOL)cansee
{
    
}

- (void)configWithModel:(DTieEditModel *)model
{
    self.model = model;
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
}

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
    
    if ([[DDLocationManager shareManager] contentIsCanSeeWith:dtieModel detailModle:model]) {
        self.detailImageView.userInteractionEnabled = YES;
        self.coverView.hidden = YES;
    }else{
        self.detailImageView.userInteractionEnabled = NO;
        self.coverView.hidden = NO;
    }
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    if (dtieModel.authorId == [UserManager shareManager].user.cid) {
        
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
            self.quanxianImageView.hidden = YES;
        }else{
            [self.quanxianImageView setImage:[UIImage imageNamed:imageName]];
            self.quanxianImageView.hidden = NO;
        }
        if (isEmptyString(imageName)) {
            [self.detailImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-24 * scale);
            }];
            self.quanxianImageView.hidden = YES;
        }else{
            [self.detailImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-96 * scale);
            }];
            [self.quanxianImageView setImage:[UIImage imageNamed:imageName]];
            self.quanxianImageView.hidden = NO;
        }
    }
}

- (void)yulanWithModel:(DTieEditModel *)model
{
    if (model.image) {
        [self.detailImageView setImage:model.image];
    }else{
        [self.detailImageView setImage:[UIImage imageNamed:@"hengBG"]];
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
