//
//  DTieImageCollectionViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/20.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieImageCollectionViewCell.h"
#import "DDViewFactoryTool.h"
#import "DDTool.h"
#import <UIImageView+WebCache.h>
#import <Masonry.h>
#import "DDShareManager.h"
#import "DDLocationManager.h"
#import "UserManager.h"

@interface DTieImageCollectionViewCell ()

@property (nonatomic, strong) UIImageView * detailImageView;
@property (nonatomic, strong) DTieModel * dtieModel;
@property (nonatomic, strong) DTieEditModel * model;

@property (nonatomic, strong) UIVisualEffectView * effectView;
@property (nonatomic, strong) UIView * converView;
@property (nonatomic, strong) UILabel * deedaoLabel;

@property (nonatomic, strong) UIView * baseView;

@end

@implementation DTieImageCollectionViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createDetailImageCell];
    }
    return self;
}

- (void)createDetailImageCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.baseView];
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.right.mas_equalTo(-30 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(0.1f);
    }];
    self.baseView.layer.cornerRadius = 24 * scale;
    self.baseView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    self.baseView.layer.shadowOpacity = .3f;
    self.baseView.layer.shadowRadius = 12 * scale;
    self.baseView.layer.shadowOffset = CGSizeMake(0, 6 * scale);
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.detailImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.detailImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.baseView addSubview:self.detailImageView];
    [self.detailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.detailImageView];
    
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDidHandle:)];
    self.detailImageView.userInteractionEnabled = YES;
    [self.detailImageView addGestureRecognizer:longPress];
    
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
}

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
    
    [[DDShareManager shareManager] showHandleViewWithImage:model];
}

- (void)configWithModel:(DTieEditModel *)model Dtie:(DTieModel *)dtieModel
{
    self.model = model;
    self.dtieModel = dtieModel;
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    CGFloat height = 0.1f;
    if (model.image) {
        [self.detailImageView setImage:model.image];
        CGFloat imageScale = model.image.size.height / model.image.size.width;
        height = (kMainBoundsWidth - 360 * scale) * imageScale;
    }else{
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:model.detailContent];
        
        if (!image) {
            [self.detailImageView setImage:[UIImage new]];
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:model.detailContent] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                
            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                [[SDImageCache sharedImageCache] storeImage:image forKey:model.detailContent toDisk:YES completion:nil];
                model.image = image;
                if (model == self.model) {
                    [self.detailImageView setImage:model.image];
                    CGFloat imageScale = model.image.size.height / model.image.size.width;
                    CGFloat result = (kMainBoundsWidth - 360 * scale) * imageScale;
                    [self.baseView mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(result);
                    }];
                }
            }];
        }else{
            model.image = image;
            [self.detailImageView setImage:model.image];
            CGFloat imageScale = model.image.size.height / model.image.size.width;
            height = (kMainBoundsWidth - 360 * scale) * imageScale;
        }
    }
    CGFloat maxHeight = kMainBoundsHeight - (kStatusBarHeight + 824) * scale - 60 * scale;
    if (height > maxHeight) {
        height = maxHeight;
    }
    [self.baseView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
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
            self.detailImageView.userInteractionEnabled = NO;
            self.converView.hidden = NO;
        }
    }
}

@end
