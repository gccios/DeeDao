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
#import "DDLGSideViewController.h"
#import "UserYaoYueBlockModel.h"
#import "DTieYaoyueBlockView.h"
#import "ChangeWYYStatusRequest.h"

@interface DTieReadHandleFooterView ()

@property (nonatomic, strong) DTieModel * model;
@property (nonatomic, strong) NSArray * yaoyueList;
@property (nonatomic, strong) UIView * yaoyueView;

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
    
    self.timeLabel.text = [NSString stringWithFormat:@"最后更新时间：%@", [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.model.createTime]];
    
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

- (void)configWithYaoyueModel:(NSArray *)models
{
    self.yaoyueList = models;
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    [self.yaoyueView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (!self.yaoyueView.superview) {
        [self addSubview:self.yaoyueView];
    }
    
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0xCCCCCC);
    [self.yaoyueView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.top.mas_equalTo(59 * scale);
        make.height.mas_equalTo(2 * scale);
    }];
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentCenter];
    titleLabel.backgroundColor = UIColorFromRGB(0xEFEFF4);
    titleLabel.text = @"邀请好友";
    [self.yaoyueView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(310 * scale);
        make.height.mas_equalTo(72 * scale);
        make.centerY.mas_equalTo(lineView);
    }];
    
    if (models.count > 0) {
        
        NSInteger postID = self.model.cid;
        if (postID == 0) {
            postID = self.model.postId;
        }
        for (NSInteger i = 0; i < models.count; i++) {
            UserYaoYueBlockModel * model = [models objectAtIndex:i];
            model.postID = postID;
            DTieYaoyueBlockView * view = [[DTieYaoyueBlockView alloc] initWithBlockModel:model];
            [self.yaoyueView addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo((i+1) * 144 * scale);
                make.left.right.mas_equalTo(0);
                make.height.mas_equalTo(144 * scale);
            }];
        }
        
        NSInteger count = models.count + 1;
        CGFloat height = 144 * scale * count + 60 * scale;
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"userId == %d", [UserManager shareManager].user.cid];
        NSArray * tempArray = [models filteredArrayUsingPredicate:predicate];
        if (tempArray.count == 0) {
            height = height + 144 * scale;
            
            UIButton * handleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"我也要加入聚会"];
            [self.yaoyueView addSubview:handleButton];
            [handleButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(60 * scale);
                make.right.mas_equalTo(-60 * scale);
                make.bottom.mas_equalTo(-50 * scale);
                make.height.mas_equalTo(120 * scale);
            }];
            [handleButton setBackgroundColor:UIColorFromRGB(0xDB6283)];
            [DDViewFactoryTool cornerRadius:60 * scale withView:handleButton];
            [handleButton addTarget:self action:@selector(addButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self.yaoyueView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(60 * scale);
            make.right.mas_equalTo(-60 * scale);
            make.top.mas_equalTo(50 * scale);
            make.height.mas_equalTo(height);
        }];
        
        [self.readLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(height + 144 * scale);
        }];
    }else if (models){
        
        UIButton * handleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"我也要加入聚会"];
        [self.yaoyueView addSubview:handleButton];
        [handleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(60 * scale);
            make.right.mas_equalTo(-60 * scale);
            make.bottom.mas_equalTo(-50 * scale);
            make.height.mas_equalTo(120 * scale);
        }];
        [handleButton setBackgroundColor:UIColorFromRGB(0xDB6283)];
        [DDViewFactoryTool cornerRadius:60 * scale withView:handleButton];
        [handleButton addTarget:self action:@selector(addButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        
        NSInteger postID = self.model.cid;
        if (postID == 0) {
            postID = self.model.postId;
        }
        
        CGFloat height = 144 * scale * 2 + 60 * scale;
        
        [self.yaoyueView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(60 * scale);
            make.right.mas_equalTo(-60 * scale);
            make.top.mas_equalTo(50 * scale);
            make.height.mas_equalTo(height);
        }];
        
        [self.readLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(height + 144 * scale);
        }];
    }
}

- (void)createDTieReadHandleView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.yaoyueView = [[UIView alloc] initWithFrame:CGRectZero];
    self.yaoyueView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self addSubview:self.yaoyueView];
    self.yaoyueView.layer.cornerRadius = 24 * scale;
    self.yaoyueView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    self.yaoyueView.layer.shadowOpacity = .3f;
    self.yaoyueView.layer.shadowRadius = 24 * scale;
    self.yaoyueView.layer.shadowOffset = CGSizeMake(0, 12 * scale);
    
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
        make.top.mas_equalTo(self.readLabel.mas_bottom).offset(70 * scale);
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
        make.width.mas_equalTo(120 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    
    self.yaoyueNumberShowLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentCenter];
    self.yaoyueNumberShowLabel.backgroundColor = UIColorFromRGB(0xDB6283);
    [self.yaoyueNumberLabel addSubview:self.yaoyueNumberShowLabel];
    [self.yaoyueNumberShowLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(30 * scale);
        make.width.mas_equalTo(42 * scale); 
        make.height.mas_equalTo(42 * scale);
    }];
    [DDViewFactoryTool cornerRadius:21 * scale withView:self.yaoyueNumberShowLabel];
    self.yaoyueNumberShowLabel.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.yaoyueNumberShowLabel.layer.borderWidth = 2 * scale;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDidClicked)];
    self.yaoyueNumberLabel.userInteractionEnabled = YES;
    [self.yaoyueNumberLabel addGestureRecognizer:tap];
    
    UIButton * backHomeButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:@"返回首页"];
    [DDViewFactoryTool cornerRadius:24 * scale withView:backHomeButton];
    backHomeButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    backHomeButton.layer.borderWidth = 3 * scale;
    [self addSubview:backHomeButton];
    [backHomeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(144 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.bottom.mas_equalTo(-30 * scale);
    }];
    [backHomeButton addTarget:self action:@selector(backHomeButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backHomeButtonDidClicked
{
    if (self.backButtonDidClicked) {
        self.backButtonDidClicked();
    }
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
                DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                UINavigationController * na = (UINavigationController *)lg.rootViewController;
                [na pushViewController:share animated:YES];
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"获取阅读信息失败" inView:[UIApplication sharedApplication].keyWindow];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:[UIApplication sharedApplication].keyWindow];
        
    }];
}

- (void)tapDidClicked
{
    DDYaoYueViewController * yaoyue = [[DDYaoYueViewController alloc] initWithDtieModel:self.model];
    
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
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

- (void)addButtonDidClicked
{
    NSInteger postID = self.model.cid;
    if (postID == 0) {
        postID = self.model.postId;
    }
    ChangeWYYStatusRequest * request =  [[ChangeWYYStatusRequest alloc] initWithPostID:postID subType:1];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        if (self.addButtonDidClickedHandle) {
            self.addButtonDidClickedHandle();
        }
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
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
            [MBProgressHUD showTextHUDWithText:@"您刚标识了您想约这里。约点越多，被约越多。Deedao好友越多，被约越多。记得常去约饭约玩活地图 组饭局哦。" inView:[UIApplication sharedApplication].keyWindow];
            
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
