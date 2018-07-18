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
#import "DDYaoYueViewController.h"
#import "SelectPostSeeRequest.h"
#import "DTieSeeModel.h"
#import "DTieSeeShareViewController.h"
#import "MBProgressHUD+DDHUD.h"

@interface DTieReadHandleFooterView ()

@property (nonatomic, strong) DTieModel * model;

@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UIButton * handleButton;
@property (nonatomic, strong) UIButton * shoucangButton;
@property (nonatomic, strong) UIButton * yaoyueButton;
@property (nonatomic, strong) UILabel * yaoyueNumberLabel;
@property (nonatomic, strong) UILabel * yaoyueNumberShowLabel;
@property (nonatomic, strong) UILabel * shoucangNumberLabel;

@property (nonatomic, strong) UILabel * readLabel;
@property (nonatomic, strong) UIButton * readButton;
@property (nonatomic, strong) UIButton * jubaoButton;

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
    model.readTimes += 1;
    self.model = model;
    
    self.timeLabel.text = [NSString stringWithFormat:@"最后更新时间：%@", [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.model.sceneTime]];
    
    if (model.authorId == [UserManager shareManager].user.cid) {
        self.handleButton.hidden = NO;
        self.jubaoButton.hidden = YES;
        self.readButton.hidden = NO;
    }else{
        self.handleButton.hidden = YES;
        self.jubaoButton.hidden = NO;
        self.readButton.hidden = YES;
    }
    
    NSString * readText = @"0";
    if (model.readTimes > 0) {
        readText = [NSString stringWithFormat:@"%ld", model.readTimes];
    }
    if (model.readTimes > 10000) {
        readText = @"10000+";
    }
    self.readLabel.text = [NSString stringWithFormat:@"阅读量：%@", readText];

    
    [self reloadStatus];
}

- (void)createDTieReadHandleView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.readLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.readLabel.text = @"阅读量";
    [self addSubview:self.readLabel];
    [self.readLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(50 * scale);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    self.readButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0XDB6283) title:@"查看阅读地图"];
    [self addSubview:self.readButton];
    [self.readButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.readLabel);
        make.width.mas_equalTo(260 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    [self.readButton addTarget:self action:@selector(readButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [DDViewFactoryTool cornerRadius:12 * scale withView:self.readButton];
    self.readButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.readButton.layer.borderWidth = 3 * scale;
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(170 * scale);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    self.handleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0XDB6283) title:@"查看D帖权限"];
    [self addSubview:self.handleButton];
    [self.handleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.timeLabel);
        make.width.mas_equalTo(260 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    [self.handleButton addTarget:self action:@selector(handleButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [DDViewFactoryTool cornerRadius:12 * scale withView:self.handleButton];
    self.handleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.handleButton.layer.borderWidth = 3 * scale;
    
    self.jubaoButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0XDB6283) title:@" 举报"];
    [self.jubaoButton setImage:[UIImage imageNamed:@"jubaoyes"] forState:UIControlStateNormal];
    [self addSubview:self.jubaoButton];
    [self.jubaoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.timeLabel);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    [self.jubaoButton addTarget:self action:@selector(handleButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    
    self.shoucangButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xDB6282) title:@""];
    [self.shoucangButton setImage:[UIImage imageNamed:@"shoucangno"] forState:UIControlStateNormal];
//    self.shoucangButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.shoucangButton];
    [self.shoucangButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(45 * scale);
        make.centerX.mas_equalTo(-kMainBoundsWidth / 4);
        make.height.mas_equalTo(120 * scale);
//        make.width.mas_equalTo(200 * scale);
    }];
    [self.shoucangButton addTarget:self action:@selector(shoucangButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.shoucangNumberLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    [self addSubview:self.shoucangNumberLabel];
    [self.shoucangNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(40 * scale);
        make.left.mas_equalTo(self.shoucangButton.mas_right).offset(0 * scale);
        make.width.mas_equalTo(100 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    
    self.yaoyueButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xDB6282) title:@""];
    [self.yaoyueButton setImage:[UIImage imageNamed:@"yaoyueno"] forState:UIControlStateNormal];
    [self addSubview:self.yaoyueButton];
    [self.yaoyueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(45 * scale);
        make.centerX.mas_equalTo(kMainBoundsWidth / 4);
        make.height.mas_equalTo(120 * scale);
    }];
    [self.yaoyueButton addTarget:self action:@selector(yaoyueButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.yaoyueNumberLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    [self addSubview:self.yaoyueNumberLabel];
    [self.yaoyueNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(40 * scale);
        make.left.mas_equalTo(self.yaoyueButton.mas_right).offset(0 * scale);
        make.width.mas_equalTo(100 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    
    self.yaoyueNumberShowLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentCenter];
    [self.yaoyueNumberLabel addSubview:self.yaoyueNumberShowLabel];
    [self.yaoyueNumberShowLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(10 * scale);
        make.width.mas_equalTo(42 * scale); 
        make.height.mas_equalTo(42 * scale);
    }];
    [DDViewFactoryTool cornerRadius:21 * scale withView:self.yaoyueNumberShowLabel];
    self.yaoyueNumberShowLabel.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.yaoyueNumberShowLabel.layer.borderWidth = 2 * scale;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDidClicked)];
    self.yaoyueNumberLabel.userInteractionEnabled = YES;
    [self.yaoyueNumberLabel addGestureRecognizer:tap];
}

- (void)readButtonDidTouchUpInside
{
    NSInteger postID = self.model.cid;
    if (postID == 0) {
        postID = self.model.postId;
    }
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:[UIApplication sharedApplication].keyWindow];
    
    SelectPostSeeRequest * request = [[SelectPostSeeRequest alloc] initWithPostID:postID];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                NSMutableArray * dataSource = [[NSMutableArray alloc] init];
                for (NSDictionary * info in data) {
                    DTieSeeModel * model = [DTieSeeModel mj_objectWithKeyValues:info];
                    [dataSource addObject:model];
                }
                DTieSeeShareViewController * share = [[DTieSeeShareViewController alloc] initWithSource:dataSource model:self.model];
                UITabBarController * tab = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                UINavigationController * na = (UINavigationController *)tab.selectedViewController;
                [na pushViewController:share animated:YES];
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"获取阅读信息失败" inView:[UIApplication sharedApplication].keyWindow];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"获取阅读信息失败" inView:[UIApplication sharedApplication].keyWindow];
        
    }];
}

- (void)tapDidClicked
{
    DDYaoYueViewController * yaoyue = [[DDYaoYueViewController alloc] initWithDtieModel:self.model];
    
    UITabBarController * tab = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)tab.selectedViewController;
    [na pushViewController:yaoyue animated:YES];
}

- (void)reloadStatus
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    if (self.model.wyyFlg) {
        [self.yaoyueButton setTitle:@"" forState:UIControlStateNormal];
        [self.yaoyueButton setImage:[UIImage imageNamed:@"yaoyueyes"] forState:UIControlStateNormal];
        self.yaoyueButton.alpha = .5f;
    }else{
        [self.yaoyueButton setTitle:@"" forState:UIControlStateNormal];
        [self.yaoyueButton setImage:[UIImage imageNamed:@"yaoyueno"] forState:UIControlStateNormal];
        self.yaoyueButton.alpha = 1.f;
    }
    
    if (self.model.wyyCount <= 0) {
        self.yaoyueNumberShowLabel.text = @"0";
        [self.yaoyueNumberShowLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(42 * scale);
        }];
    }else if(self.model.wyyCount < 100){
        self.yaoyueNumberShowLabel.text = [NSString stringWithFormat:@"%ld", self.model.wyyCount];
        
        if (self.model.wyyCount < 10) {
            [self.yaoyueNumberShowLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(42 * scale);
            }];
        }else {
            [self.yaoyueNumberShowLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(80 * scale);
            }];
        }
        
    }else{
        self.yaoyueNumberShowLabel.text = @"99+";
        [self.yaoyueNumberShowLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(80 * scale);
        }];
    }
    
    if (self.model.authorId == [UserManager shareManager].user.cid) {
        
        self.shoucangButton.alpha = 1.f;
        
        [self.shoucangButton setImage:[UIImage imageNamed:@"zuozheshoucang"] forState:UIControlStateNormal];
        
        if (self.model.collectCount <= 0) {
            self.shoucangNumberLabel.text = @" 0";
        }else if(self.model.collectCount < 100){
            self.shoucangNumberLabel.text = [NSString stringWithFormat:@" %ld", self.model.collectCount];
        }else{
            self.shoucangNumberLabel.text = @" 99+";
        }
        self.shoucangNumberLabel.hidden = NO;
        
    }else{
        
        self.shoucangNumberLabel.hidden = YES;
        
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
            [MBProgressHUD showTextHUDWithText:@"您已要约当前地点，点击要约数字，联系您想约的好友吧" inView:[UIApplication sharedApplication].keyWindow];
            
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
