//
//  DTieSingleImageShareView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieSingleImageShareView.h"
#import <UIImageView+WebCache.h>
#import <Masonry.h>
#import "MBProgressHUD+DDHUD.h"
#import "WeChatManager.h"
#import "GCCScreenImage.h"
#import "GetWXAccessTokenRequest.h"

@interface DTieSingleImageShareView ()

@property (nonatomic, strong) UserModel * model;
@property (nonatomic, strong) UIImageView * logoImageView;

@end

@implementation DTieSingleImageShareView

- (instancetype)initWithModel:(UserModel *)model
{
    if (self = [super init]) {
        self.model = model;
        [self configShareView];
    }
    return self;
}

- (void)startShare
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:[UIApplication sharedApplication].keyWindow];
    
    GetWXAccessTokenRequest * request = [[GetWXAccessTokenRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSDictionary *dict = [response objectForKey:@"data"];
            if (KIsDictionary(dict)) {
                [WeChatManager shareManager].miniProgramToken = [dict objectForKey:@"access_token"];
            }
        }
        
        NSInteger userID = self.model.cid;
        
        [[WeChatManager shareManager] getMiniProgromCodeWithUserID:userID handle:^(UIImage *image) {
            
            if (image) {
                [self.logoImageView setImage:image];
            }else{
//                [self.logoImageView setImage:[UIImage imageNamed:@"gongzhongCode"]];
            }
            
            [self share];
            [hud hideAnimated:YES];
        }];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        
    }];
}

- (void)share
{
    UIImage * shareImage = [GCCScreenImage screenView:self];
    [[WeChatManager shareManager] shareImage:shareImage];
    [self removeFromSuperview];
}

- (void)configShareView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    self.backgroundColor = [UIColor whiteColor];
    self.frame = CGRectMake(0, 0, kMainBoundsWidth, 1600 * scale);
    
    UIView * BGView = [[UIView alloc] initWithFrame:CGRectZero];
    BGView.backgroundColor = [UIColor whiteColor];
    [self addSubview:BGView];
    [BGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(90 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(BGView.mas_width);
    }];
    BGView.layer.cornerRadius = 24 * scale;
    BGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    BGView.layer.shadowOpacity = .3f;
    BGView.layer.shadowRadius = 12 * scale;
    BGView.layer.shadowOffset = CGSizeMake(0, 6 * scale);
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.model.portraituri]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(90 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(imageView.mas_width);
    }];
    imageView.layer.cornerRadius = 24 * scale;
    imageView.clipsToBounds = YES;
    
    UIView * logoBGView = [[UIView alloc] initWithFrame:CGRectZero];
    logoBGView.backgroundColor = [UIColor whiteColor];
    [self addSubview:logoBGView];
    [logoBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom).offset(-132 * scale);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(264 * scale);
    }];
    logoBGView.layer.cornerRadius = 132 * scale;
    logoBGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    logoBGView.layer.shadowOpacity = .5f;
    logoBGView.layer.shadowRadius = 24 * scale;
    logoBGView.layer.shadowOffset = CGSizeMake(0, 12 * scale);
    
    self.logoImageView = [[UIImageView alloc] init];
    [logoBGView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo(220 * scale);
    }];
    self.logoImageView.layer.cornerRadius = 80 * scale;
    self.logoImageView.clipsToBounds = YES;
    
    UIImageView * letterImageview = [[UIImageView alloc] init];
    [letterImageview setImage:[UIImage imageNamed:@"letterLogo"]];
    [imageView addSubview:letterImageview];
    [letterImageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.width.mas_equalTo(168 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = kPingFangRegular(36 * scale);
    label.textColor = UIColorFromRGB(0x333333);
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 2;
    label.text = @"长按图片识别小程序  加入DeeDao地到\n和我一起在真实的世界里  延续彼此的精彩";
    [self addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.logoImageView.mas_bottom).offset(60 * scale);
    }];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(120 * scale);
        make.bottom.mas_equalTo(-119 * scale);
        make.right.mas_equalTo(-120 * scale);
        make.height.mas_equalTo(3 * scale);
    }];
    
    UILabel * tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    tipLabel.backgroundColor = [UIColor whiteColor];
    tipLabel.font = kPingFangRegular(36 * scale);
    tipLabel.textColor = UIColorFromRGB(0xCCCCCC);
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.text = @"www.deedao.com";
    [self addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(lineView);
        make.width.mas_equalTo(420 * scale);
        make.height.mas_equalTo(60 * scale);
    }];
}

@end
