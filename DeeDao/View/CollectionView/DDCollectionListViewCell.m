//
//  DDCollectionListViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/16.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDCollectionListViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import "DTieDetailRequest.h"
#import "DTieImageCollectionViewCell.h"
#import "DTieTextCollectionViewCell.h"
#import "DTieVideoCollectionViewCell.h"
#import "DTiePostCollectionViewCell.h"
#import "DTieTitleCollectionViewCell.h"
#import "DDLocationManager.h"
#import "TYCyclePagerView.h"
#import "UserManager.h"
#import "MBProgressHUD+DDHUD.h"
#import "DTieCancleWYYRequest.h"
#import "DTieCancleCollectRequest.h"
#import "DTieCollectionRequest.h"
#import "DDDazhaohuView.h"
#import "UserInfoViewController.h"
#import "DDYaoYueViewController.h"
#import "DDTool.h"
#import "DDDaZhaoHuViewController.h"
#import "DDLGSideViewController.h"

@interface DDCollectionListViewCell ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton * shoucangButton;
@property (nonatomic, strong) UIButton * yaoyueButton;
@property (nonatomic, strong) UILabel * yaoyueNumberLabel;
@property (nonatomic, strong) UILabel * yaoyueNumberShowLabel;
@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UIButton * dazhaohuButton;

@property (nonatomic, strong) DTieModel * model;
@property (nonatomic, assign) BOOL isFirstRead;
@property (nonatomic, assign) NSIndexPath * firestIndex;
@property (nonatomic, strong) UIView * baseView;
//@property (nonatomic, strong) UIImageView * collectImageView;

@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, strong) DTieDetailRequest * request;
@property (nonatomic, strong) UILabel * shoucangNumberLabel;

@end

@implementation DDCollectionListViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createListViewCell];
    }
    return self;
}

- (void)dazhaohuButtonDidClicked
{
    DTieModel * model = self.model;
    
    if (model.authorId == [UserManager shareManager].user.cid) {
        
        DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        UINavigationController * na = (UINavigationController *)lg.rootViewController;
        DDDaZhaoHuViewController * dazhaohu = [[DDDaZhaoHuViewController alloc] initWithDTieModel:self.model];
        [na pushViewController:dazhaohu animated:YES];
        
        return;
    }
    
    if (model.dzfFlg == 1) {
        [MBProgressHUD showTextHUDWithText:@"您已经打过招呼了" inView:[UIApplication sharedApplication].keyWindow];
        return;
    }
    
    BOOL canHandle = [[DDLocationManager shareManager] postIsCanDazhaohuWith:model];
    if (!canHandle) {
        [MBProgressHUD showTextHUDWithText:[NSString stringWithFormat:@"只能和%ld米之内的的帖子打招呼", [DDLocationManager shareManager].distance] inView:[UIApplication sharedApplication].keyWindow];
        return;
    }
    
    DDDazhaohuView * view = [[DDDazhaohuView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.block = ^(NSString *text) {
        self.dazhaohuButton.enabled = NO;
        
        DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:model.cid type:2 subType:1 remark:@""];
        
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            model.dzfFlg = 1;
            model.dzfCount++;
            [self reloadStatus];
            
            self.dazhaohuButton.enabled = YES;
            [MBProgressHUD showTextHUDWithText:@"对方已收到您的打招呼" inView:[UIApplication sharedApplication].keyWindow];
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.dazhaohuButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.dazhaohuButton.enabled = YES;
        }];
    };
    [view show];
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

- (void)createListViewCell
{
    self.dataSource = [[NSMutableArray alloc] init];
    
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.baseView = [[UIView alloc] init];
    self.baseView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.contentView addSubview:self.baseView];
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.bottom.right.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.baseView];
    
    self.shoucangButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xDB6282) title:@""];
    [self.shoucangButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 10 * scale, 0)];
    [self.shoucangButton setImage:[UIImage imageNamed:@"shoucangno"] forState:UIControlStateNormal];
    [self.baseView addSubview:self.shoucangButton];
    [self.shoucangButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(50 * scale);
        make.left.mas_equalTo(10 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    [self.shoucangButton addTarget:self action:@selector(shoucangButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.shoucangNumberLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    [self addSubview:self.shoucangNumberLabel];
    [self.shoucangNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(45 * scale);
        make.right.mas_equalTo(0 * scale);
        make.height.mas_equalTo(120 * scale);
        make.left.mas_equalTo(self.shoucangButton.mas_right).offset(0 * scale);
    }];
    
    self.yaoyueButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xDB6282) title:@" 要约"];
    [self.yaoyueButton setImage:[UIImage imageNamed:@"yaoyueno"] forState:UIControlStateNormal];
    [self.baseView addSubview:self.yaoyueButton];
    [self.yaoyueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(50 * scale);
        make.right.mas_equalTo(-90 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    [self.yaoyueButton addTarget:self action:@selector(yaoyueButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.yaoyueNumberLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    [self.baseView addSubview:self.yaoyueNumberLabel];
    [self.yaoyueNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(45 * scale);
        make.right.mas_equalTo(0 * scale);
        make.height.mas_equalTo(120 * scale);
        make.left.mas_equalTo(self.yaoyueButton.mas_right).offset(0 * scale);
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
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = self.baseView.backgroundColor;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = kMainBoundsHeight - (kStatusBarHeight + 824) * scale;
    self.tableView.pagingEnabled = YES;
    [self.tableView registerClass:[DTieVideoCollectionViewCell class] forCellReuseIdentifier:@"DTieVideoCollectionViewCell"];
    [self.tableView registerClass:[DTieImageCollectionViewCell class] forCellReuseIdentifier:@"DTieImageCollectionViewCell"];
    [self.tableView registerClass:[DTieTextCollectionViewCell class] forCellReuseIdentifier:@"DTieTextCollectionViewCell"];
    [self.tableView registerClass:[DTieTitleCollectionViewCell class] forCellReuseIdentifier:@"DTieTitleCollectionViewCell"];
    [self.tableView registerClass:[DTiePostCollectionViewCell class] forCellReuseIdentifier:@"DTiePostCollectionViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.baseView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((144 + 30) * scale);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-230 * scale);
    }];
    
    UIView * logoBGView = [[UIView alloc] initWithFrame:CGRectZero];
    logoBGView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:logoBGView];
    [logoBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.bottom.mas_equalTo(-90 * scale);
        make.height.width.mas_equalTo(96 * scale);
    }];
    logoBGView.layer.cornerRadius = 48 * scale;
    logoBGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    logoBGView.layer.shadowOpacity = .3f;
    logoBGView.layer.shadowRadius = 4 * scale;
    logoBGView.layer.shadowOffset = CGSizeMake(0, 2 * scale);
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [logoBGView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:48 * scale withView:self.logoImageView];
    UITapGestureRecognizer * tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookUserInfo)];
    self.logoImageView.userInteractionEnabled = YES;
    [self.logoImageView addGestureRecognizer:tap1];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(20 * scale);
        make.right.mas_equalTo(-300 * scale);
        make.centerY.mas_equalTo(self.logoImageView);
        make.height.mas_equalTo(50 * scale);
    }];
    UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookUserInfo)];
    self.nameLabel.userInteractionEnabled = YES;
    [self.nameLabel addGestureRecognizer:tap2];
    
    self.dazhaohuButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@""];
    [self.contentView addSubview:self.dazhaohuButton];
    [self.dazhaohuButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-30 * scale);
        make.width.mas_equalTo(268 * scale);
        make.centerY.mas_lessThanOrEqualTo(self.logoImageView);
        make.height.mas_equalTo(148 * scale);
    }];
    [self.dazhaohuButton addTarget:self action:@selector(dazhaohuButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDidClicked)];
    self.yaoyueNumberLabel.userInteractionEnabled = YES;
    [self.yaoyueNumberLabel addGestureRecognizer:tap];
    
//    self.collectImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
//    [self addSubview:self.collectImageView];
//    [self.collectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(0 * scale);
//        make.right.mas_equalTo(-40 * scale);
//        make.width.mas_equalTo(60 * scale);
//        make.height.mas_equalTo(400 * scale);
//    }];
}

- (void)tapDidClicked
{
    DDYaoYueViewController * yaoyue = [[DDYaoYueViewController alloc] initWithDtieModel:self.model];
    
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    [na pushViewController:yaoyue animated:YES];
}

- (void)lookUserInfo
{
    DTieModel * model = self.model;
    if (model) {
        DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        UINavigationController * na = (UINavigationController *)lg.rootViewController;
        UserInfoViewController * info = [[UserInfoViewController alloc] initWithUserId:model.authorId];
        [na pushViewController:info animated:YES];
    }
}

- (void)configWithModel:(DTieModel *)model tag:(NSInteger)tag
{
    self.request = nil;
    self.model = model;
    
    self.tableView.tag = tag;
    self.isFirstRead = YES;
    
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
    self.nameLabel.text = model.nickname;
    [self reloadStatus];
//
//    if (model.wyyFlg) {
//        [self.collectImageView setImage:[UIImage imageNamed:@"yaoyueshu"]];
//        self.collectImageView.hidden = NO;
//    }else if (model.collectFlg) {
//        [self.collectImageView setImage:[UIImage imageNamed:@"shoucangshu"]];
//        self.collectImageView.hidden = NO;
//    }else{
//        self.collectImageView.hidden = YES;
//    }
    
    if (model.details) {
        
        NSMutableArray * tempArray = [[NSMutableArray alloc] initWithArray:model.details];
        for (NSInteger i = 0; i < tempArray.count; i++) {
            DTieEditModel * editModel = [tempArray objectAtIndex:i];
            if (editModel.type == DTieEditType_Image) {
                [tempArray removeObject:editModel];
                break;
            }
        }
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:tempArray];
        
        [self.tableView setContentOffset:CGPointZero animated:NO];
        [self.tableView reloadData];
        return;
    }
    
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    
//    [DTieDetailRequest cancelRequest];
    
    NSInteger postID = model.postId;
    if (postID == 0) {
        postID = model.cid;
    }
    
    self.request = [[DTieDetailRequest alloc] initWithID:postID type:4 start:0 length:10];
    [self.request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                [model mj_setKeyValues:data];
                
                if (request == self.request) {
                    NSMutableArray * tempArray = [[NSMutableArray alloc] initWithArray:model.details];
                    for (NSInteger i = 0; i < tempArray.count; i++) {
                        DTieEditModel * editModel = [tempArray objectAtIndex:i];
                        if (editModel.type == DTieEditType_Image) {
                            [tempArray removeObject:editModel];
                            break;
                        }
                    }
                    [self.dataSource removeAllObjects];
                    [self.dataSource addObjectsFromArray:tempArray];
                    
                    [self.tableView setContentOffset:CGPointZero animated:NO];
                    [self.tableView reloadData];
                }
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
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
                make.width.mas_equalTo(60 * scale);
            }];
        }
        
    }else{
        self.yaoyueNumberShowLabel.text = @"99+";
        [self.yaoyueNumberShowLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(60 * scale);
        }];
    }
    
    if (self.model.authorId == [UserManager shareManager].user.cid) {
        
        self.dazhaohuButton.alpha = 1.f;
        self.shoucangButton.alpha = 1.f;
        
        [self.dazhaohuButton setTitle:[NSString stringWithFormat:@"打招呼 %ld", self.model.dzfCount] forState:UIControlStateNormal];
        if (self.model.dzfCount > 100) {
            [self.dazhaohuButton setTitle:@" 打招呼 99+" forState:UIControlStateNormal];
        }
        [self.dazhaohuButton setImage:[UIImage imageNamed:@"dazhaohuzuozhe"] forState:UIControlStateNormal];
        
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
        
        [self.dazhaohuButton setTitle:@"" forState:UIControlStateNormal];
        [self.dazhaohuButton setImage:[UIImage imageNamed:@"dazhaohuzuoyou"] forState:UIControlStateNormal];
        
        if ([[DDLocationManager shareManager] postIsCanDazhaohuWith:self.model]) {
            self.dazhaohuButton.alpha = 1.f;
        }else{
            self.dazhaohuButton.alpha = .5f;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        DTieEditModel * model = [[DTieEditModel alloc] init];
        model.type = DTieEditType_Image;
        model.detailContent = self.model.postFirstPicture;
        DTieTitleCollectionViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieTitleCollectionViewCell" forIndexPath:indexPath];
        [cell configWithModel:model Dtie:self.model];
        return cell;
    }
    
    DTieEditModel * model = [self.dataSource objectAtIndex:indexPath.row - 1];
    
    if (model.type == DTieEditType_Image) {
        DTieImageCollectionViewCell * imageCell = [tableView dequeueReusableCellWithIdentifier:@"DTieImageCollectionViewCell" forIndexPath:indexPath];
        [imageCell configWithModel:model Dtie:self.model];
        return imageCell;
    }else if (model.type == DTieEditType_Text){
        DTieTextCollectionViewCell * textCell = [tableView dequeueReusableCellWithIdentifier:@"DTieTextCollectionViewCell" forIndexPath:indexPath];
        [textCell configWithModel:model Dtie:self.model];
        return textCell;
    }else if (model.type == DTieEditType_Video) {
        DTieVideoCollectionViewCell * videoCell = [tableView dequeueReusableCellWithIdentifier:@"DTieVideoCollectionViewCell" forIndexPath:indexPath];
        [videoCell configWithModel:model Dtie:self.model];
        return videoCell;
    }else if (model.type == DTieEditType_Post) {
        DTiePostCollectionViewCell * postCell = [tableView dequeueReusableCellWithIdentifier:@"DTiePostCollectionViewCell" forIndexPath:indexPath];
        [postCell configWithModel:model Dtie:self.model];
        return postCell;
    }
    
    DTieImageCollectionViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieImageCollectionViewCell" forIndexPath:indexPath];
    
    [cell configWithModel:model Dtie:self.model];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableViewClickHandle) {
        self.tableViewClickHandle([NSIndexPath indexPathForItem:tableView.tag inSection:0]);
    }
}

@end
