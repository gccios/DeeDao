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

@interface DTieDetailVideoTableViewCell ()

@property (nonatomic, strong) UIImageView * detailImageView;
@property (nonatomic, strong) UIImageView * playImageView;;
@property (nonatomic, strong) DTieEditModel * model;

@property (nonatomic, strong) UIVisualEffectView * effectView;

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
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    self.effectView.alpha = .98f;
    [self.contentView addSubview:self.effectView];
    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo(150 * scale);
    }];
    self.effectView.hidden = YES;
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

- (void)configWithModel:(DTieEditModel *)model Dtie:(id)dtieModel
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
    
    if ([[DDLocationManager shareManager] contentIsCanSeeWith:dtieModel detailModle:model]) {
        self.detailImageView.userInteractionEnabled = YES;
        self.effectView.hidden = NO;
    }else{
        self.detailImageView.userInteractionEnabled = NO;
        self.effectView.hidden = YES;
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
