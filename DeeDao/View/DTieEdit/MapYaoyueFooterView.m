//
//  MapYaoyueFooterView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/11/8.
//  Copyright © 2018 郭春城. All rights reserved.
//

#import "MapYaoyueFooterView.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import "UserManager.h"
#import "DDLocationManager.h"
#import "DTieCollectionRequest.h"
#import "DDDazhaohuView.h"
#import "MBProgressHUD+DDHUD.h"
#import "DTiePOIViewController.h"
#import "DDLGSideViewController.h"

@interface MapYaoyueFooterView ()

@property (nonatomic, strong) DTieModel * model;

@property (nonatomic, strong) UIButton * leftButton;
@property (nonatomic, strong) UIButton * centerButton;
@property (nonatomic, strong) UIButton * rightButton;

@end

@implementation MapYaoyueFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createDtieCollectionFooterView];
    }
    return self;
}

- (void)leftButtonDidClicked
{
//    if (self.model.authorId == [UserManager shareManager].user.cid) {
//        if (self.deleteHandle) {
//            self.deleteHandle();
//        }
//    }else{
        self.leftButton.enabled = NO;
        if (self.model.wyyFlg) {
            
            DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            UINavigationController * na = (UINavigationController *)lg.rootViewController;
            
            if (self.hiddenHandle) {
                self.hiddenHandle();
            }
            
            DTiePOIViewController * list = [[DTiePOIViewController alloc] initWithDtieModel:self.model];
            [na pushViewController:list animated:YES];
            
        }else{
            DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:self.model.cid type:1 subType:0 remark:@""];
            
            [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                
                self.model.wyyFlg = 1;
                self.model.wyyCount++;
                [self configWithDTieModel:self.model];
                
                self.leftButton.enabled = YES;
            } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                self.leftButton.enabled = YES;
            } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
                self.leftButton.enabled = YES;
            }];
        }
//    }
}

- (void)centerButtonDidClicked
{
    if (self.model.authorId == [UserManager shareManager].user.cid) {
        
        if (self.uploadHandle) {
            self.uploadHandle();
        }
        
    }else{
        DDDazhaohuView * view = [[DDDazhaohuView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        view.block = ^(NSString *text) {
            self.centerButton.enabled = NO;
            
            DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:self.model.cid type:2 subType:1 remark:text];
            
            [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                
                self.model.dzfFlg = 1;
                self.model.dzfCount++;
                
                self.centerButton.enabled = YES;
                [MBProgressHUD showTextHUDWithText:@"对方已收到您的信息" inView:[UIApplication sharedApplication].keyWindow];
            } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                self.centerButton.enabled = YES;
            } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
                self.centerButton.enabled = YES;
            }];
        };
        [view show];
    }
}

- (void)rightButtonDidClicked
{
    if (self.yaoyueHandle) {
        self.yaoyueHandle();
    }
}

- (void)createDtieCollectionFooterView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    CGFloat distance = (kMainBoundsWidth - 3 * 300 * scale) / 4.f;
    self.leftButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@""];
    [self.leftButton setBackgroundColor:[UIColor whiteColor]];
    [self.leftButton addTarget:self action:@selector(leftButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.leftButton];
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(distance);
        make.height.mas_equalTo(120 * scale);
        make.width.mas_equalTo(300 * scale);
        make.top.mas_equalTo(40 * scale);
    }];
    [DDViewFactoryTool cornerRadius:60 * scale withView:self.leftButton];
    self.leftButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.leftButton.layer.borderWidth = 4 * scale;
    
    self.centerButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@""];
    [self.centerButton addTarget:self action:@selector(centerButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.centerButton setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:self.centerButton];
    [self.centerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftButton.mas_right).offset(distance);
        make.height.mas_equalTo(120 * scale);
        make.width.mas_equalTo(300 * scale);
        make.top.mas_equalTo(40 * scale);
    }];
    [DDViewFactoryTool cornerRadius:60 * scale withView:self.centerButton];
    self.centerButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.centerButton.layer.borderWidth = 4 * scale;
    
    self.rightButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@""];
    [self.rightButton addTarget:self action:@selector(rightButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:self.rightButton];
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.centerButton.mas_right).offset(distance);
        make.height.mas_equalTo(120 * scale);
        make.width.mas_equalTo(300 * scale);
        make.top.mas_equalTo(40 * scale);
    }];
    [DDViewFactoryTool cornerRadius:60 * scale withView:self.rightButton];
    self.rightButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.rightButton.layer.borderWidth = 4 * scale;
}

- (void)configWithDTieModel:(DTieModel *)model
{
    self.model = model;
    NSString * number = @"";
    if (self.model.wyyCount > 0) {
        number = [NSString stringWithFormat:@"%ld", self.model.wyyCount];
        if (self.model.wyyCount > 99) {
            number = @"99+";
        }
    }
    
    if (model.authorId == [UserManager shareManager].user.cid) {
//        [self.leftButton setTitle:DDLocalizedString(@"Delete") forState:UIControlStateNormal];
        
        if (model.wyyFlg == 1) {
            [self.leftButton setTitle:[NSString stringWithFormat:@"%@ %@", DDLocalizedString(@"HasInterestedHome"), number] forState:UIControlStateNormal];
            self.leftButton.alpha = .5f;
        }else{
            [self.leftButton setTitle:DDLocalizedString(@"InterestedHome") forState:UIControlStateNormal];
            self.leftButton.alpha = 1.f;
        }
        
        [self.centerButton setTitle:DDLocalizedString(@"AddPhotos") forState:UIControlStateNormal];
        [self.rightButton setTitle:DDLocalizedString(@"OrganizeHere") forState:UIControlStateNormal];
    }else{
        if (model.wyyFlg == 1) {
            [self.leftButton setTitle:[NSString stringWithFormat:@"%@ %@", DDLocalizedString(@"HasInterestedHome"), number] forState:UIControlStateNormal];
            self.leftButton.alpha = .5f;
        }else{
            [self.leftButton setTitle:DDLocalizedString(@"InterestedHome") forState:UIControlStateNormal];
            self.leftButton.alpha = 1.f;
        }
        [self.centerButton setTitle:DDLocalizedString(@"SayHi") forState:UIControlStateNormal];
        [self.rightButton setTitle:DDLocalizedString(@"OrganizeHere") forState:UIControlStateNormal];
        
        if ([[DDLocationManager shareManager] postIsCanDazhaohuWith:model]) {
            self.centerButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
            [self.centerButton setTitleColor:UIColorFromRGB(0xDB6283) forState:UIControlStateNormal];
            self.centerButton.enabled = YES;
        }else{
            self.centerButton.layer.borderColor = UIColorFromRGB(0xefeff4).CGColor;
            [self.centerButton setTitleColor:UIColorFromRGB(0xefeff4) forState:UIControlStateNormal];
            self.centerButton.enabled = NO;
        }
    }
}

@end
