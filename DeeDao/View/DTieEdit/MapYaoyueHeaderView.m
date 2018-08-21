//
//  MapYaoyueHeaderView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/25.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "MapYaoyueHeaderView.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import "UserManager.h"
#import "DTieCancleWYYRequest.h"
#import "DTieCollectionRequest.h"
#import "DTieCancleCollectRequest.h"
#import "MBProgressHUD+DDHUD.h"

@interface MapYaoyueHeaderView ()

@property (nonatomic, strong) UIImageView * logoImageView;

@property (nonatomic, strong) UIImageView * contenImageView;

@property (nonatomic, strong) UILabel * DTieTitleLabel;

@property (nonatomic, strong) UIImageView * markImageView;

@property (nonatomic, strong) UIView * titleView;

@property (nonatomic, strong) UIButton * collectButton;
@property (nonatomic, strong) UIButton * yaoyueButton;
//@property (nonatomic, strong) UILabel * yaoyueNumberLabel;
//@property (nonatomic, strong) UILabel * yaoyueNumberShowLabel;
@property (nonatomic, strong) DTieModel * model;

@end

@implementation MapYaoyueHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createDtieCollectionCell];
    }
    return self;
}

- (void)showPostDetail
{
    if (self.postHandle) {
        self.postHandle();
    }
}

- (void)showUserDetail
{
    if (self.userHandle) {
        self.userHandle();
    }
}

- (void)createDtieCollectionCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.contenImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    self.contenImageView.userInteractionEnabled = YES;
    [self addSubview:self.contenImageView];
    [self.contenImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(30 * scale);
        make.left.mas_equalTo(60 * scale);
        make.width.mas_equalTo(450 * scale);
        make.height.mas_equalTo(270 * scale);
    }];
    self.contenImageView.layer.cornerRadius = 20 * scale;
    self.contenImageView.layer.masksToBounds = YES;
    self.contenImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer * postTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPostDetail)];
    [self.contenImageView addGestureRecognizer:postTap];
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [self addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contenImageView.mas_left).offset(-20 * scale);
        make.top.mas_equalTo(0 * scale);
        make.width.height.mas_equalTo(96 * scale);
    }];
    [DDViewFactoryTool cornerRadius:48 * scale withView:self.logoImageView];
    self.logoImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer * userTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUserDetail)];
    [self.logoImageView addGestureRecognizer:userTap];
    
    self.titleView = [[UIView alloc] init];
    self.titleView.backgroundColor = [UIColorFromRGB(0x111111) colorWithAlphaComponent:.7f];
    [self.contenImageView addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(85 * scale);
    }];
    
    self.DTieTitleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentLeft];
    [self.titleView addSubview:self.DTieTitleLabel];
    [self.DTieTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(18 * scale);
        make.left.mas_equalTo(24 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(40 * scale);
    }];
    
    self.markImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"DTieCollection"]];
    [self addSubview:self.markImageView];
    [self.markImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0 * scale);
        make.width.mas_equalTo(60 * scale);
        make.height.mas_equalTo(348 * scale);
        make.right.mas_equalTo(self.contenImageView.mas_right).offset(-40 * scale);
    }];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(120 * scale);
        make.right.mas_equalTo(-120 * scale);
        make.height.mas_equalTo(2 * scale);
        make.bottom.mas_equalTo(-40 * scale);
    }];
    
    UILabel * tipLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentCenter];
    tipLabel.text = @"所有约这的好友";
    tipLabel.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(lineView);
        make.width.mas_equalTo(400 * scale);
        make.height.mas_equalTo(60 * scale);
    }];
    
    self.collectButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xDB6282) title:@""];
    [self.collectButton setImage:[UIImage imageNamed:@"shoucangno"] forState:UIControlStateNormal];
    [self addSubview:self.collectButton];
    [self.collectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contenImageView).offset(-70 * scale);
        make.left.mas_equalTo(self.contenImageView.mas_right).offset(200 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    [self.collectButton addTarget:self action:@selector(collectButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.yaoyueButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xDB6282) title:@""];
    [self.yaoyueButton setImage:[UIImage imageNamed:@"yaoyueno"] forState:UIControlStateNormal];
    [self addSubview:self.yaoyueButton];
    [self.yaoyueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contenImageView).offset(70 * scale);
        make.left.mas_equalTo(self.contenImageView.mas_right).offset(200 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    [self.yaoyueButton addTarget:self action:@selector(yaoyueButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
//    self.yaoyueNumberLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
//    [self addSubview:self.yaoyueNumberLabel];
//    [self.yaoyueNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(self.contenImageView);
//        make.left.mas_equalTo(self.yaoyueButton.mas_right).offset(0 * scale);
//        make.width.mas_equalTo(100 * scale);
//        make.height.mas_equalTo(120 * scale);
//    }];
//
//    self.yaoyueNumberShowLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentCenter];
//    [self.yaoyueNumberLabel addSubview:self.yaoyueNumberShowLabel];
//    [self.yaoyueNumberShowLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(-5 * scale);
//        make.left.mas_equalTo(10 * scale);
//        make.width.mas_equalTo(42 * scale);
//        make.height.mas_equalTo(42 * scale);
//    }];
//    [DDViewFactoryTool cornerRadius:21 * scale withView:self.yaoyueNumberShowLabel];
//    self.yaoyueNumberShowLabel.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
//    self.yaoyueNumberShowLabel.layer.borderWidth = 2 * scale;
//
//    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDidClicked)];
//    self.yaoyueNumberLabel.userInteractionEnabled = YES;
//    [self.yaoyueNumberLabel addGestureRecognizer:tap];
}

//- (void)tapDidClicked
//{
//    if (self.yaoyueHandle) {
//        self.yaoyueHandle();
//    }
//}

- (void)yaoyueButtonDidClicked
{
    DTieModel * model = self.model;
    
    self.yaoyueButton.enabled = NO;
    if (model.wyyFlg) {
        
        DTieCancleWYYRequest * request = [[DTieCancleWYYRequest alloc] initWithPostID:model.cid];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            model.wyyFlg = 0;
            model.wyyCount--;
            if (self.yaoyueHandle) {
                self.yaoyueHandle();
            }
            [self reloadStatus];
            
            self.yaoyueButton.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.yaoyueButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.yaoyueButton.enabled = YES;
        }];
        
    }else{
        DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:model.cid type:1 subType:0 remark:@""];
        
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            model.wyyFlg = 1;
            model.wyyCount++;
            if (self.yaoyueHandle) {
                self.yaoyueHandle();
            }
            [MBProgressHUD showTextHUDWithText:@"您刚标识了您想约这里。约点越多，被约越多。Deedao好友越多，被约越多。记得常去约饭约玩活地图 组饭局哦" inView:[UIApplication sharedApplication].keyWindow];
            
            [self reloadStatus];
            
            self.yaoyueButton.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.yaoyueButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.yaoyueButton.enabled = YES;
        }];
    }
}

- (void)collectButtonDidClicked
{
    DTieModel * model = self.model;
    
    self.collectButton.enabled = NO;
    if (model.collectFlg) {
        
        DTieCancleCollectRequest * request = [[DTieCancleCollectRequest alloc] initWithPostID:model.cid];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            model.collectFlg = 0;
            model.collectCount--;
            [self reloadStatus];
            
            self.collectButton.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.collectButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.collectButton.enabled = YES;
        }];
        
    }else{
        DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:model.cid type:0 subType:0 remark:@""];
        
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            model.collectFlg = 1;
            model.collectCount++;
            [self reloadStatus];
            
            self.collectButton.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.collectButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.collectButton.enabled = YES;
        }];
    }
}

- (void)reloadStatus
{
//    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    if (self.model.wyyFlg == 1) {
        [self.yaoyueButton setTitle:@"" forState:UIControlStateNormal];
        [self.yaoyueButton setImage:[UIImage imageNamed:@"yaoyueyes"] forState:UIControlStateNormal];
        self.yaoyueButton.alpha = .5f;
    }else{
        [self.yaoyueButton setTitle:@"" forState:UIControlStateNormal];
        [self.yaoyueButton setImage:[UIImage imageNamed:@"yaoyueno"] forState:UIControlStateNormal];
        self.yaoyueButton.alpha = 1.f;
    }
    
    if (self.model.collectFlg == 1) {
        [self.collectButton setTitle:@"" forState:UIControlStateNormal];
        [self.collectButton setImage:[UIImage imageNamed:@"shoucangyes"] forState:UIControlStateNormal];
        self.collectButton.alpha = .5f;
    }else{
        [self.collectButton setTitle:@"" forState:UIControlStateNormal];
        [self.collectButton setImage:[UIImage imageNamed:@"shoucangno"] forState:UIControlStateNormal];
        self.collectButton.alpha = 1.f;
    }
    
//    if (self.model.wyyCount <= 0) {
//        self.yaoyueNumberShowLabel.text = @"0";
//        [self.yaoyueNumberShowLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.width.mas_equalTo(42 * scale);
//        }];
//    }else if(self.model.wyyCount < 100){
//        self.yaoyueNumberShowLabel.text = [NSString stringWithFormat:@"%ld", self.model.wyyCount];
//
//        if (self.model.wyyCount < 10) {
//            [self.yaoyueNumberShowLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.width.mas_equalTo(42 * scale);
//            }];
//        }else {
//            [self.yaoyueNumberShowLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.width.mas_equalTo(80 * scale);
//            }];
//        }
//
//    }else{
//        self.yaoyueNumberShowLabel.text = @"99+";
//        [self.yaoyueNumberShowLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.width.mas_equalTo(80 * scale);
//        }];
//    }
}

- (void)configWithDTieModel:(DTieModel *)model
{
    self.model = model;
    
    if (!isEmptyString(model.postSummary)) {
        self.DTieTitleLabel.text = model.postSummary;
    }else{
        self.DTieTitleLabel.text = @"";
    }
    
    NSURL * imageURL = [NSURL URLWithString:model.postFirstPicture];
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
    [self.contenImageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"list_bg"]];
    
    if (model.collectFlg == 1) {
        [self.markImageView setImage:[UIImage imageNamed:@"DTieCollection"]];
        self.markImageView.hidden = NO;
        self.titleView.hidden = NO;
    }else if (model.wyyFlg == 1) {
        [self.markImageView setImage:[UIImage imageNamed:@"DTieBeFoundTo"]];
        self.markImageView.hidden = NO;
        self.titleView.hidden = NO;
    }else{
        self.markImageView.hidden = YES;
        self.titleView.hidden = NO;
    }
    [self reloadStatus];
}

@end
