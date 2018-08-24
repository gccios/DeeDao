//
//  DTieVideoCollectionViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/20.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieVideoCollectionViewCell.h"
#import "DDViewFactoryTool.h"
#import "DDTool.h"
#import <UIImageView+WebCache.h>
#import <Masonry.h>
#import "DDShareManager.h"
#import "DDLocationManager.h"
#import "UserManager.h"

@interface DTieVideoCollectionViewCell ()

@property (nonatomic, strong) UIImageView * detailImageView;
@property (nonatomic, strong) UIImageView * playImageView;;
@property (nonatomic, strong) DTieModel * dtieModel;
@property (nonatomic, strong) DTieEditModel * model;

@property (nonatomic, strong) UIVisualEffectView * effectView;
@property (nonatomic, strong) UIView * converView;
@property (nonatomic, strong) UILabel * deedaoLabel;

@property (nonatomic, strong) UIView * baseView;

@end

@implementation DTieVideoCollectionViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createDetailVideoCell];
    }
    return self;
}

- (void)createDetailVideoCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.baseView];
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.right.mas_equalTo(-30 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo((kMainBoundsWidth - 360 * scale) / 4.f * 3.f);
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
    
    self.playImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.playImageView setImage:[UIImage imageNamed:@"player"]];
    [self.baseView addSubview:self.playImageView];
    [self.playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo(150 * scale);
    }];
    
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

- (void)configWithModel:(DTieEditModel *)model Dtie:(DTieModel *)dtieModel
{
    self.model = model;
    self.dtieModel = dtieModel;
    if (model.image) {
        [self.detailImageView setImage:model.image];
    }else{
        
        [self.detailImageView sd_setImageWithURL:[NSURL URLWithString:model.detailContent] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            model.image = image;
        }];
    }
    
    if (nil == dtieModel) {
        return;
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
}

@end
