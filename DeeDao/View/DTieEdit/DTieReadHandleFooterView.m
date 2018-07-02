//
//  DTieReadHandleFooterView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieReadHandleFooterView.h"
#import "DDViewFactoryTool.h"
#import "UserManager.h"
#import "DTieCancleWYYRequest.h"
#import "DTieCancleCollectRequest.h"
#import "DTieCollectionRequest.h"
#import <Masonry.h>
#import "DDTool.h"

@interface DTieReadHandleFooterView ()

@property (nonatomic, strong) DTieModel * model;

@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UIButton * handleButton;
@property (nonatomic, strong) UIButton * shoucangButton;
@property (nonatomic, strong) UIButton * yaoyueButton;

@end

@implementation DTieReadHandleFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self createDTieReadHandleView];
    }
    return self;
}

- (void)configWithModel:(DTieModel *)model
{
    self.model = model;
    
    self.timeLabel.text = [NSString stringWithFormat:@"最后更新时间：%@", [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.model.sceneTime]];
    
    if (model.authorId == [UserManager shareManager].user.cid) {
        [self.handleButton setTitle:@"查看D帖权限" forState:UIControlStateNormal];
        [self.handleButton setImage:[UIImage new] forState:UIControlStateNormal];
    }else{
        [self.handleButton setTitle:@" 举报" forState:UIControlStateNormal];
        [self.handleButton setImage:[UIImage imageNamed:@"jubaoyes"] forState:UIControlStateNormal];
    }
    
    [self reloadStatus];
}

- (void)createDTieReadHandleView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(50 * scale);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    self.handleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0XDB6283) title:@""];
    [self addSubview:self.handleButton];
    [self.handleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.timeLabel);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    [self.handleButton addTarget:self action:@selector(handleButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    
    self.shoucangButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xDB6282) title:@""];
    [self.shoucangButton setImage:[UIImage imageNamed:@"shoucangno"] forState:UIControlStateNormal];
//    self.shoucangButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.shoucangButton];
    [self.shoucangButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(40 * scale);
        make.centerX.mas_equalTo(-kMainBoundsWidth / 4);
        make.height.mas_equalTo(120 * scale);
//        make.width.mas_equalTo(200 * scale);
    }];
    [self.shoucangButton addTarget:self action:@selector(shoucangButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.yaoyueButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xDB6282) title:@""];
    [self.yaoyueButton setImage:[UIImage imageNamed:@"yaoyueno"] forState:UIControlStateNormal];
    [self addSubview:self.yaoyueButton];
    [self.yaoyueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(40 * scale);
        make.centerX.mas_equalTo(kMainBoundsWidth / 4);
        make.height.mas_equalTo(120 * scale);
    }];
    [self.yaoyueButton addTarget:self action:@selector(yaoyueButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)reloadStatus
{
    if (self.model.authorId == [UserManager shareManager].user.cid) {
        
        self.yaoyueButton.alpha = 1.f;
        self.shoucangButton.alpha = 1.f;
        
        [self.yaoyueButton setImage:[UIImage imageNamed:@"yaoyueno"] forState:UIControlStateNormal];
        [self.shoucangButton setImage:[UIImage imageNamed:@"shoucangno"] forState:UIControlStateNormal];
        if (self.model.wyyCount <= 0) {
            [self.yaoyueButton setTitle:@"0" forState:UIControlStateNormal];
        }else if(self.model.wyyCount < 100){
            [self.yaoyueButton setTitle:[NSString stringWithFormat:@"%ld", self.model.wyyCount] forState:UIControlStateNormal];
        }else{
            [self.yaoyueButton setTitle:@"99+" forState:UIControlStateNormal];
        }
        
        if (self.model.collectCount <= 0) {
            [self.shoucangButton setTitle:@"0" forState:UIControlStateNormal];
        }else if(self.model.collectCount < 100){
            [self.shoucangButton setTitle:[NSString stringWithFormat:@"%ld", self.model.collectCount] forState:UIControlStateNormal];
        }else{
            [self.shoucangButton setTitle:@"99+" forState:UIControlStateNormal];
        }
        
    }else{
        if (self.model.wyyFlg) {
            [self.yaoyueButton setTitle:@"" forState:UIControlStateNormal];
            [self.yaoyueButton setImage:[UIImage imageNamed:@"yaoyueyes"] forState:UIControlStateNormal];
            self.yaoyueButton.alpha = .5f;
        }else{
            [self.yaoyueButton setTitle:@"" forState:UIControlStateNormal];
            [self.yaoyueButton setImage:[UIImage imageNamed:@"yaoyueno"] forState:UIControlStateNormal];
            self.yaoyueButton.alpha = 1.f;
        }
        
        if (self.model.collectFlg) {
            [self.shoucangButton setTitle:@"" forState:UIControlStateNormal];
            [self.shoucangButton setImage:[UIImage imageNamed:@"shoucangyes"] forState:UIControlStateNormal];
            self.shoucangButton.alpha = .5f;
        }else{
            [self.shoucangButton setTitle:@"" forState:UIControlStateNormal];
            [self.shoucangButton setImage:[UIImage imageNamed:@"shoucangno"] forState:UIControlStateNormal];
            self.shoucangButton.alpha = 1.f;
        }
    }
}

- (void)handleButtonDidTouchUpInside
{
    if (self.handleButtonDidClicked) {
        self.handleButtonDidClicked();
    }
}

- (void)shoucangButtonDidClicked
{
    DTieModel * model = self.model;
    
    if (model.authorId == [UserManager shareManager].user.cid) {
        //        [MBProgressHUD showTextHUDWithText:@"无法对自己的帖子进行该操作" inView:[UIApplication sharedApplication].keyWindow];
        return;
    }
    
    self.shoucangButton.enabled = NO;
    if (model.collectFlg) {
        
        DTieCancleCollectRequest * request = [[DTieCancleCollectRequest alloc] initWithPostID:model.cid];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            model.collectFlg = 0;
            model.collectCount--;
            [self reloadStatus];
            
            self.shoucangButton.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.shoucangButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.shoucangButton.enabled = YES;
        }];
        
    }else{
        DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:model.cid type:0 subType:0 remark:@""];
        
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            model.collectFlg = 1;
            model.collectCount++;
            [self reloadStatus];
            
            self.shoucangButton.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.shoucangButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.shoucangButton.enabled = YES;
        }];
    }
}

- (void)yaoyueButtonDidClicked
{
    DTieModel * model = self.model;
    
    if (model.authorId == [UserManager shareManager].user.cid) {
        //        [MBProgressHUD showTextHUDWithText:@"无法对自己的帖子进行该操作" inView:[UIApplication sharedApplication].keyWindow];
        return;
    }
    
    self.yaoyueButton.enabled = NO;
    if (model.wyyFlg) {
        
        DTieCancleWYYRequest * request = [[DTieCancleWYYRequest alloc] initWithPostID:model.cid];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            model.wyyFlg = 0;
            model.wyyCount--;
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
            [self reloadStatus];
            
            self.yaoyueButton.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.yaoyueButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.yaoyueButton.enabled = YES;
        }];
    }
}

@end
