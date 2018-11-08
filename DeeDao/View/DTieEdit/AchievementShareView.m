//
//  AchievementShareView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "AchievementShareView.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import "UserManager.h"
#import "DDTool.h"
#import "MBProgressHUD+DDHUD.h"
#import "WeChatManager.h"
#import "GetWXAccessTokenRequest.h"
#import "GCCScreenImage.h"

@interface AchievementShareView ()

@property (nonatomic, strong) AchievementModel * model;
@property (nonatomic, strong) UIImage * image;
@property (nonatomic, assign) NSInteger type;

@property (nonatomic, strong) UIImageView * logoImageView;

@end

@implementation AchievementShareView

- (instancetype)initWithAchievementModel:(AchievementModel *)model currentImage:(UIImage *)image type:(NSInteger)type
{
    if (self = [super init]) {
        self.model = model;
        self.image = image;
        self.type = type;
        [self createAchievementModel];
    }
    return self;
}

- (void)startShare
{
    [[UIApplication sharedApplication].keyWindow insertSubview:self atIndex:0];
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:[UIApplication sharedApplication].keyWindow];
    
    GetWXAccessTokenRequest * request = [[GetWXAccessTokenRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSDictionary *dict = [response objectForKey:@"data"];
            if (KIsDictionary(dict)) {
                [WeChatManager shareManager].miniProgramToken = [dict objectForKey:@"access_token"];
            }
        }
        
        NSInteger postID = self.model.medalObjectId;
        
        [[WeChatManager shareManager] getMiniProgromCodeWithPostID:postID handle:^(UIImage *image) {
            
            if (image) {
                [self.logoImageView setImage:image];
            }else{
                [self.logoImageView setImage:[UIImage imageNamed:@"gongzhongCode"]];
            }
            [hud hideAnimated:YES];
            [self share];
            
        }];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.logoImageView setImage:[UIImage imageNamed:@"gongzhongCode"]];
        [hud hideAnimated:YES];
        [self share];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [self.logoImageView setImage:[UIImage imageNamed:@"gongzhongCode"]];
        [hud hideAnimated:YES];
        [self share];
        
    }];
}

- (void)share
{
    UIImage * image = [GCCScreenImage screenView:self];
    
    if (self.type == 1) {
        [[WeChatManager shareManager] shareImage:image];
    }else if (self.type == 2) {
        [[WeChatManager shareManager] shareFriendImage:image];
    }else if (self.type == 3) {
        [DDTool userLibraryAuthorizationStatusWithSuccess:^{
            
            [DDTool saveImageInSystemPhoto:image];
        } failure:^{
            [MBProgressHUD showTextHUDWithText:@"没有相册访问权限" inView:[UIApplication sharedApplication].keyWindow];
        }];
    }
    
    [self removeFromSuperview];
}

- (void)createAchievementModel
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.frame = CGRectMake(0, 0, 1080 * scale, 1920 * scale);
    self.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"chengjiuBG"]];
    [self addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(500 * scale);
    }];
    
    UIImageView * myImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [myImageView sd_setImageWithURL:[NSURL URLWithString:[UserManager shareManager].user.portraituri]];
    [imageView addSubview:myImageView];
    [myImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(-40 * scale);
        make.width.height.mas_equalTo(220 * scale);
    }];
    [DDViewFactoryTool cornerRadius:110 * scale withView:myImageView];
    
    UIImageView * contentImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFit image:self.image];
    [self addSubview:contentImageView];
    [contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(500 * scale);
        make.bottom.mas_equalTo(-220 * scale);
    }];
    
    UIView * whiteView = [[UIView alloc] initWithFrame:CGRectZero];
    whiteView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [contentImageView addSubview:whiteView];
    [whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(150 * scale);
        make.right.mas_equalTo(-150 * scale);
        make.height.mas_equalTo(230 * scale);
    }];
    
    UIView * logoBGView = [[UIView alloc] initWithFrame:CGRectZero];
    logoBGView.backgroundColor = [UIColor whiteColor];
    [whiteView addSubview:logoBGView];
    [logoBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.centerY.mas_equalTo(0);
        make.height.width.mas_equalTo(96 * scale);
    }];
    logoBGView.layer.cornerRadius = 48 * scale;
    logoBGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    logoBGView.layer.shadowOpacity = .3f;
    logoBGView.layer.shadowRadius = 4 * scale;
    logoBGView.layer.shadowOffset = CGSizeMake(0, 2 * scale);
    
    UIImageView * userImageview = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [logoBGView addSubview:userImageview];
    [userImageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:48 * scale withView:userImageview];
    [userImageview sd_setImageWithURL:[NSURL URLWithString:self.model.medalObjectImg]];
    
    UILabel * nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    [whiteView addSubview:nameLabel];
    [nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(logoBGView.mas_right).offset(20 * scale);
        make.right.mas_equalTo(-300 * scale);
        make.centerY.mas_equalTo(logoBGView);
    }];
    nameLabel.text = self.model.medalObjectTitle;
    
    UIView * logoBGView2 = [[UIView alloc] initWithFrame:CGRectZero];
    logoBGView2.backgroundColor = [UIColor whiteColor];
    [self addSubview:logoBGView2];
    [logoBGView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-120 * scale);
        make.bottom.mas_equalTo(-250 * scale);
        make.width.height.mas_equalTo(264 * scale);
    }];
    logoBGView2.layer.cornerRadius = 132 * scale;
    logoBGView2.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    logoBGView2.layer.shadowOpacity = .5f;
    logoBGView2.layer.shadowRadius = 24 * scale;
    logoBGView2.layer.shadowOffset = CGSizeMake(0, 12 * scale);
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [logoBGView2 addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo(220 * scale);
    }];
    self.logoImageView.layer.cornerRadius = 80 * scale;
    self.logoImageView.clipsToBounds = YES;
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentCenter];
    titleLabel.numberOfLines = 2;
    titleLabel.text = [NSString stringWithFormat:@"%@ 我揭开了%@\n到地可见的面纱", [DDTool getTimeWithFormat:@"yyyy年MM月" time:self.model.createTime], self.model.medalObjectUsername];
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(40 * scale);
        make.left.right.mas_equalTo(0);
    }];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(120 * scale);
        make.bottom.mas_equalTo(-131 * scale);
        make.right.mas_equalTo(-120 * scale);
        make.height.mas_equalTo(3 * scale);
    }];
    
    UILabel * tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    tipLabel.backgroundColor = [UIColor whiteColor];
    tipLabel.font = kPingFangRegular(36 * scale);
    tipLabel.textColor = UIColorFromRGB(0x333333);
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.text = @"发布于Deedao地到APP";
    [self addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(lineView);
        make.width.mas_equalTo(450 * scale);
        make.height.mas_equalTo(60 * scale);
    }];
}

@end
