//
//  DDCollectionViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/16.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDCollectionViewController.h"
#import "TYCyclePagerView.h"
#import "DDCollectionListViewCell.h"
#import "DDHandleButton.h"
#import <UIImageView+WebCache.h>
#import "DTieCollectionRequest.h"
#import "DTieCancleCollectRequest.h"
#import "DTieCancleWYYRequest.h"
#import "MBProgressHUD+DDHUD.h"
#import "DTieDetailRequest.h"
#import "DTieNewDetailViewController.h"
#import "DTieNewEditViewController.h"
#import "UserInfoViewController.h"
#import "DDShareManager.h"
#import "UserManager.h"
#import "DDDTieViewController.h"
#import "DTiePOIViewController.h"
#import "DDDazhaohuView.h"
#import "DDLocationManager.h"

@interface DDCollectionViewController ()<TYCyclePagerViewDataSource, TYCyclePagerViewDelegate>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * locationLabel;
@property (nonatomic, strong) DDHandleButton * yaoyueButton;
@property (nonatomic, strong) DDHandleButton * shoucangButton;
@property (nonatomic, strong) DDHandleButton * dazhaohuButton;

@property (nonatomic, strong) TYCyclePagerView *pagerView;

@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, assign) NSInteger index;

@end

@implementation DDCollectionViewController

- (instancetype)initWithDataSource:(NSArray *)dataSource index:(NSInteger)index
{
    if (self = [super init]) {
        self.dataSource = [[NSMutableArray alloc] initWithArray:dataSource];
        self.index = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
    [self createTopView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCurrentPage) name:DTieCollectionNeedUpdateNotification object:nil];
}

- (void)reloadCurrentPage
{
    DTieModel * model = [self.dataSource objectAtIndex:self.pagerView.curIndex];
    model.details = nil;
    
    [self.pagerView.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.pagerView.curIndex inSection:0]]];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.pagerView = [[TYCyclePagerView alloc]init];
    self.pagerView.isInfiniteLoop = YES;
    self.pagerView.dataSource = self;
    self.pagerView.delegate = self;
    self.pagerView.isInfiniteLoop = NO;
    [self.pagerView registerClass:[DDCollectionListViewCell class] forCellWithReuseIdentifier:@"DDCollectionListViewCell"];
    
    [self.view addSubview:self.pagerView];
    [self.pagerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + 144 + kStatusBarHeight) * scale);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-210 * scale);
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.pagerView scrollToItemAtIndex:self.index animate:NO];
    });
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"test"]];
    [self.view addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((244 + kStatusBarHeight) * scale);
        make.left.mas_equalTo(120 * scale);
        make.width.height.mas_equalTo(96 *scale);
    }];
    [DDViewFactoryTool cornerRadius:48 * scale withView:self.logoImageView];
    UITapGestureRecognizer * tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookUserInfo)];
    self.logoImageView.userInteractionEnabled = YES;
    [self.logoImageView addGestureRecognizer:tap1];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x000000) alignment:NSTextAlignmentLeft];
    self.nameLabel.userInteractionEnabled = YES;
    [self.view addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.logoImageView);
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(15 * scale);
        make.height.mas_equalTo(60 * scale);
    }];
    UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookUserInfo)];
    [self.nameLabel addGestureRecognizer:tap2];
    
    UIImageView * locationImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"location"]];
    [self.view addSubview:locationImageView];
    [locationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pagerView.mas_bottom).offset(40 * scale);
        make.left.mas_equalTo(self.logoImageView);
        make.width.height.mas_equalTo(50 * scale);
    }];
    
    self.locationLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.locationLabel.numberOfLines = 0;
    [self.view addSubview:self.locationLabel];
    [self.locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pagerView.mas_bottom).offset(25 * scale);
        make.left.mas_equalTo(locationImageView.mas_right).offset(25 * scale);
        make.width.mas_equalTo(450 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationShouldChooseNavi)];
    self.locationLabel.userInteractionEnabled = YES;
    [self.locationLabel addGestureRecognizer:tap];
    
    self.shoucangButton = [DDHandleButton buttonWithType:UIButtonTypeCustom];
    [self.shoucangButton configImage:[UIImage imageNamed:@"shoucangno"]];
    [self.shoucangButton configTitle:@"0"];
    [self.shoucangButton addTarget:self action:@selector(shoucangButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shoucangButton];
    [self.shoucangButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pagerView.mas_bottom).offset(25 * scale);
        make.left.mas_equalTo(self.locationLabel.mas_right).offset(30 * scale);
        make.width.mas_equalTo(96 * scale);
        make.height.mas_equalTo(96 * scale);
    }];
    
    self.yaoyueButton = [DDHandleButton buttonWithType:UIButtonTypeCustom];
    [self.yaoyueButton configImage:[UIImage imageNamed:@"yaoyueno"]];
    [self.yaoyueButton configTitle:@"0"];
    [self.yaoyueButton addTarget:self action:@selector(yaoyueButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.yaoyueButton];
    [self.yaoyueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pagerView.mas_bottom).offset(25 * scale);
        make.left.mas_equalTo(self.shoucangButton.mas_right).offset(10 * scale);
        make.width.mas_equalTo(96 * scale);
        make.height.mas_equalTo(96 * scale);
    }];
    
    self.dazhaohuButton = [DDHandleButton buttonWithType:UIButtonTypeCustom];
    [self.dazhaohuButton configImage:[UIImage imageNamed:@"dazhaohu"]];
    [self.dazhaohuButton configTitle:@"0"];
    [self.dazhaohuButton addTarget:self action:@selector(dazhaohuButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dazhaohuButton];
    [self.dazhaohuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pagerView.mas_bottom).offset(25 * scale);
        make.left.mas_equalTo(self.yaoyueButton.mas_right).offset(10 * scale);
        make.width.mas_equalTo(96 * scale);
        make.height.mas_equalTo(96 * scale);
    }];
}

- (void)locationShouldChooseNavi
{
    DTieModel * model = [self.dataSource objectAtIndex:self.pagerView.curIndex];
    if (model) {
        DTiePOIViewController * poi = [[DTiePOIViewController alloc] initWithDtieModel:model];
        [self.navigationController pushViewController:poi animated:YES];
    }
}

- (void)lookUserInfo
{
    DTieModel * model = [self.dataSource objectAtIndex:self.pagerView.curIndex];
    UserInfoViewController * info = [[UserInfoViewController alloc] initWithUserId:model.authorId];
    [self.navigationController pushViewController:info animated:YES];
}

- (void)yaoyueButtonDidClicked
{
    DTieModel * model = [self.dataSource objectAtIndex:self.pagerView.curIndex];
    
    if (model.authorId == [UserManager shareManager].user.cid) {
        [MBProgressHUD showTextHUDWithText:@"无法对自己的帖子进行该操作" inView:self.view];
        return;
    }
    
    self.yaoyueButton.enabled = NO;
    if (model.wyyFlg) {
        
        DTieCancleWYYRequest * request = [[DTieCancleWYYRequest alloc] initWithPostID:model.cid];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            model.wyyFlg = 0;
            model.wyyCount--;
            [self reloadPageWithIndex:self.pagerView.curIndex];
            
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
            [self reloadPageWithIndex:self.pagerView.curIndex];
            
            self.yaoyueButton.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.yaoyueButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.yaoyueButton.enabled = YES;
        }];
    }
}

- (void)shoucangButtonDidClicked
{
    DTieModel * model = [self.dataSource objectAtIndex:self.pagerView.curIndex];
    
    if (model.authorId == [UserManager shareManager].user.cid) {
        [MBProgressHUD showTextHUDWithText:@"无法对自己的帖子进行该操作" inView:self.view];
        return;
    }
    
    self.shoucangButton.enabled = NO;
    if (model.collectFlg) {
        
        DTieCancleCollectRequest * request = [[DTieCancleCollectRequest alloc] initWithPostID:model.cid];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            model.collectFlg = 0;
            model.collectCount--;
            [self reloadPageWithIndex:self.pagerView.curIndex];
            
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
            [self reloadPageWithIndex:self.pagerView.curIndex];
            
            self.shoucangButton.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.shoucangButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.shoucangButton.enabled = YES;
        }];
    }
}

- (void)dazhaohuButtonDidClicked
{
    DTieModel * model = [self.dataSource objectAtIndex:self.pagerView.curIndex];
    
    if (model.authorId == [UserManager shareManager].user.cid) {
        [MBProgressHUD showTextHUDWithText:@"无法对自己的帖子进行该操作" inView:self.view];
        return;
    }
    
    if (model.dzfFlg == 1) {
        [MBProgressHUD showTextHUDWithText:@"您已经打过招呼了" inView:self.view];
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
            [self reloadPageWithIndex:self.pagerView.curIndex];
            
            self.dazhaohuButton.enabled = YES;
            [MBProgressHUD showTextHUDWithText:@"对方已收到您的信息" inView:[UIApplication sharedApplication].keyWindow];
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.dazhaohuButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.dazhaohuButton.enabled = YES;
        }];
    };
    [view show];
}

- (void)pagerView:(TYCyclePagerView *)pageView didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    [self reloadPageWithIndex:toIndex];
}

- (void)reloadPageWithIndex:(NSInteger)index
{
    DTieModel * model = [self.dataSource objectAtIndex:index];
    
    if (model) {
        
        if (model.deleteFlg == 1) {
            
            [MBProgressHUD showTextHUDWithText:@"帖子已被作者删除" inView:self.view];
            
            [self.dataSource removeObjectAtIndex:index];
            [self.pagerView.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
            
            NSArray * vcs = self.navigationController.viewControllers;
            UIViewController * vc = [vcs objectAtIndex:vcs.count - 2];
            if ([vc isKindOfClass:[DDDTieViewController class]]) {
                DDDTieViewController * tie = (DDDTieViewController *)vc;
                [tie deleteDtieWithIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
            }
            
            return;
        }
        
        [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
        self.nameLabel.text = model.nickname;
        
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
        NSString * createTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)model.sceneTime / 1000]];
        self.locationLabel.text = [NSString stringWithFormat:@"%@\n%@", createTime, model.sceneAddress];
        
        [self.yaoyueButton configTitle:[NSString stringWithFormat:@"%ld", model.wyyCount]];
        [self.shoucangButton configTitle:[NSString stringWithFormat:@"%ld", model.collectCount]];
        [self.dazhaohuButton configTitle:[NSString stringWithFormat:@"%ld", model.dzfCount]];
        
        if (model.wyyFlg) {
           [self.yaoyueButton configImage:[UIImage imageNamed:@"yaoyueyes"]];
        }else{
            [self.yaoyueButton configImage:[UIImage imageNamed:@"yaoyueno"]];
        }
        
        BOOL canHandle = [[DDLocationManager shareManager] postIsCanDazhaohuWith:model];
        if (canHandle) {
            [self.dazhaohuButton configImage:[UIImage imageNamed:@"dazhaohuyuanyes"]];
        }else{
            [self.dazhaohuButton configImage:[UIImage imageNamed:@"dazhaohuyuanno"]];
        }
        
        if (model.collectFlg) {
            [self.shoucangButton configImage:[UIImage imageNamed:@"shoucangyes"]];
        }else{
            [self.shoucangButton configImage:[UIImage imageNamed:@"shoucangno"]];
        }
        
        if (model.authorId == [UserManager shareManager].user.cid) {
            [self.dazhaohuButton configImage:[UIImage imageNamed:@"dazhaohuyuanno"]];
        }
        
        self.titleLabel.text = model.postSummary;
    }
}

- (NSInteger)numberOfItemsInPagerView:(TYCyclePagerView *)pageView {
    return self.dataSource.count;
}

- (UICollectionViewCell *)pagerView:(TYCyclePagerView *)pagerView cellForItemAtIndex:(NSInteger)index {
    DDCollectionListViewCell *cell = [pagerView dequeueReusableCellWithReuseIdentifier:@"DDCollectionListViewCell" forIndex:index];
    
    DTieModel * model = [self.dataSource objectAtIndex:index];
    [cell configWithModel:model tag:index];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(cell) weakCell = cell;
    cell.tableViewClickHandle = ^(NSIndexPath *cellIndex) {
        [weakSelf.pagerView.delegate pagerView:weakSelf.pagerView didSelectedItemCell:weakCell atIndex:cellIndex.item];
    };
    
    return cell;
}

- (TYCyclePagerViewLayout *)layoutForPagerView:(TYCyclePagerView *)pageView {
    
    TYCyclePagerViewLayout *layout = [[TYCyclePagerViewLayout alloc]init];
    layout.itemSize = CGSizeMake(CGRectGetWidth(pageView.frame)*0.8, CGRectGetHeight(pageView.frame));
    layout.layoutType = TYCyclePagerTransformLayoutLinear;
    layout.itemHorizontalCenter = YES;
    layout.itemSpacing = 15;
    
    return layout;
}

- (void)pagerView:(TYCyclePagerView *)pageView didSelectedItemCell:(__kindof UICollectionViewCell *)cell atIndex:(NSInteger)index
{
    DTieModel * model = [self.dataSource objectAtIndex:index];
    NSInteger postID = model.postId;
    if (postID == 0) {
        postID = model.cid;
    }
    
    if (model.dTieType == DTieType_Edit) {
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在获取草稿" inView:self.view];
        
        DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:postID type:4 start:0 length:10];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
            
            if (KIsDictionary(response)) {
                NSDictionary * data = [response objectForKey:@"data"];
                if (KIsDictionary(data)) {
                    DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
                    dtieModel.postId = model.postId;
                    DTieNewEditViewController * edit = [[DTieNewEditViewController alloc] initWithDtieModel:dtieModel];
                    [self.navigationController pushViewController:edit animated:YES];
                }
            }
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            [hud hideAnimated:YES];
        }];
        return;
    }
    
    if (model.details) {
        if (model.ifCanSee == 0) {
            [MBProgressHUD showTextHUDWithText:@"您没有浏览该帖的权限~" inView:self.view];
            return;
        }
        DTieNewDetailViewController * detail = [[DTieNewDetailViewController alloc] initWithDTie:model];
        [self.navigationController pushViewController:detail animated:NO];
    }else{
        [MBProgressHUD showTextHUDWithText:@"正在获取帖子内容" inView:self.view];
    }
}

- (void)createTopView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.topView = [[UIView alloc] init];
    self.topView.userInteractionEnabled = YES;
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo((220 + kStatusBarHeight) * scale);
    }];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth, (220 + kStatusBarHeight) * scale);
    [self.topView.layer addSublayer:gradientLayer];
    
    self.topView.layer.shadowColor = UIColorFromRGB(0xB721FF).CGColor;
    self.topView.layer.shadowOpacity = .24;
    self.topView.layer.shadowOffset = CGSizeMake(0, 4);
    
    UIButton * backButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.bottom.mas_equalTo(-15 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    self.titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentLeft];
    self.titleLabel.text = @"浏览D帖";
    [self.topView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
        make.right.mas_equalTo(-210 * scale);
    }];
    
    UIButton * shareButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"0/9"];
    [shareButton setImage:[UIImage imageNamed:@"topShare"] forState:UIControlStateNormal];
    [self.topView addSubview:shareButton];
    [shareButton addTarget:self action:@selector(shareButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(-60 * scale);
        make.width.mas_equalTo(150 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    [shareButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -70 * scale, 0, 0)];
    [DDShareManager shareManager].tempNumberLabel = shareButton;
    [[DDShareManager shareManager] updateNumber];
}

- (void)shareButtonDidClicked
{
    [[DDShareManager shareManager] showShareList];
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reloadPageWithIndex:self.pagerView.curIndex];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DTieCollectionNeedUpdateNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
