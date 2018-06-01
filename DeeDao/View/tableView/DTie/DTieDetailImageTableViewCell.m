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

@interface DTieDetailImageTableViewCell ()

@property (nonatomic, strong) UIImageView * detailImageView;
@property (nonatomic, strong) DTieEditModel * model;

@property (nonatomic, strong) UIVisualEffectView * effectView;

@end

@implementation DTieDetailImageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createDetailImageCell];
    }
    return self;
}

- (void)createDetailImageCell
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.detailImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.detailImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.detailImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.detailImageView];
    [self.detailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(24 * scale);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-24 * scale);
    }];
    
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDidHandle:)];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidTap:)];
    self.detailImageView.userInteractionEnabled = YES;
    [self.detailImageView addGestureRecognizer:longPress];
    [self.detailImageView addGestureRecognizer:tap];
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    self.effectView.alpha = .98f;
    [self.contentView addSubview:self.effectView];
    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(24 * scale);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-24 * scale);
    }];
    self.effectView.hidden = YES;
}

- (void)imageDidTap:(UITapGestureRecognizer *)tap
{
    UITabBarController * tab = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)tab.selectedViewController;
    if (self.model.image) {
        LookImageViewController * look = [[LookImageViewController alloc] initWithImage:self.model.image];
        [na presentViewController:look animated:NO completion:nil];
    }else{
        LookImageViewController * look = [[LookImageViewController alloc] initWithImageURL:self.model.detailContent];
        [na presentViewController:look animated:NO completion:nil];
    }
}

- (void)configWithCanSee:(BOOL)cansee
{
    
}

- (void)longPressDidHandle:(UILongPressGestureRecognizer *)longPress
{
    [[DDShareManager shareManager] showHandleViewWithImage:self.detailImageView.image];
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
