//
//  DTieNewViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/7.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieNewViewController.h"
#import "DTieHeaderLogoCell.h"
#import "DTieNewEditViewController.h"
#import "DTieListRequest.h"
#import "MBProgressHUD+DDHUD.h"
#import "DDCollectionViewController.h"
#import <UIImageView+WebCache.h>
#import "DTieMapViewController.h"
#import "DTieDetailRequest.h"
#import "DTieSearchViewController.h"
#import "DDNavigationViewController.h"
#import "DTieDeleteRequest.h"
#import "UserManager.h"
#import <MJRefresh.h>
#import "NewAddSeriesController.h"
#import "GetSeriesRequest.h"
#import "NewSeriesCollectionViewCell.h"
#import "SeriesDetailRequest.h"
#import <AFHTTPSessionManager.h>
#import "SeriesSelectViewController.h"
#import "ShowSeriesViewController.h"
#import "DTieSearchRequest.h"
#import "DDBackWidow.h"

@interface DTieNewViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIButton * searchButton;
@property (nonatomic, strong) UIButton * mapButton;

@property (nonatomic, strong) UIButton * DTieButton;
@property (nonatomic, strong) UIButton * seriesButton;
@property (nonatomic, assign) NSInteger pageType;

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UIView * DTieView;
@property (nonatomic, strong) UICollectionView * DtieCollectionView;
@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger length;

@property (nonatomic, strong) UIView * seriesView;
@property (nonatomic, strong) UICollectionView * seriesCollectionView;
@property (nonatomic, strong) NSMutableArray * seriesDataSource;

@property (nonatomic, strong) UIView * addChooseView;
@property (nonatomic, strong) UIButton * tempAddButton;
@property (nonatomic, strong) UIButton * leftHandleButton;
@property (nonatomic, strong) UIButton * rightHandleButton;
@property (nonatomic, strong) NSIndexPath * handleIndex;
@property (nonatomic, assign) BOOL isEdit;

@end

@implementation DTieNewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isEdit = NO;
    self.start = 0;
    self.length = 20;
    
    [self createViews];
    
    [self refreshData];
    [self getSeriesData];
}

- (void)getSeriesData
{
    GetSeriesRequest * request = [[GetSeriesRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            [self.seriesDataSource removeAllObjects];
            if (KIsArray(data)) {
                [self analysisSeriesData:data];
            }
        }
        [self.seriesCollectionView.mj_header endRefreshing];
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self.seriesCollectionView.mj_header endRefreshing];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [self.seriesCollectionView.mj_header endRefreshing];
    }];
}

- (void)analysisSeriesData:(NSArray *)data
{
    [self.seriesDataSource removeAllObjects];
    NSMutableArray * topArray = [[NSMutableArray alloc] init];
    NSMutableArray * seriesArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < data.count; i++) {
        NSDictionary * info = [data objectAtIndex:i];
        NSDictionary * dict = [info objectForKey:@"series"];
        SeriesModel * model = [SeriesModel mj_objectWithKeyValues:dict];
        model.seriesFirstPicture = [info objectForKey:@"seriesFirstPicture"];
        if (model.stickyFlag) {
            [topArray addObject:model];
        }else{
            [seriesArray addObject:model];
        }
    }
    
    if (topArray.count > 0) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"stickyTime" ascending:NO];
        [topArray sortUsingDescriptors:@[sort]];
        [self.seriesDataSource addObjectsFromArray:topArray];
    }
    [self.seriesDataSource addObjectsFromArray:seriesArray];
    [self.seriesCollectionView reloadData];
}

- (void)refreshData
{
//    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:self.view];
    
    self.start = 0;
    self.length = 10;
    DTieSearchRequest * request = [[DTieSearchRequest alloc] initWithSortType:1 dataSources:1 type:2 pageStart:self.start pageSize:self.length];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
//        [hud hideAnimated:YES];
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                [self.dataSource removeAllObjects];
                for (NSDictionary * dict in data) {
                    DTieModel * model = [DTieModel mj_objectWithKeyValues:dict];
                    [self.dataSource addObject:model];
                }
                [self.DtieCollectionView reloadData];
                
                self.start = self.length;
                
            }
        }
        [self.DtieCollectionView.mj_header endRefreshing];
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
//        [hud hideAnimated:YES];
//        [MBProgressHUD showTextHUDWithText:@"获取D帖失败" inView:self.view];
        [self.DtieCollectionView.mj_header endRefreshing];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
//        [hud hideAnimated:YES];
//        [MBProgressHUD showTextHUDWithText:@"获取D帖失败" inView:self.view];
        [self.DtieCollectionView.mj_header endRefreshing];
    }];
}

- (void)getMoreList
{
    //    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:self.view];
    
    DTieSearchRequest * request = [[DTieSearchRequest alloc] initWithSortType:1 dataSources:1 type:2 pageStart:self.start pageSize:self.length];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        //        [hud hideAnimated:YES];
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data) && data.count > 0) {
                for (NSDictionary * dict in data) {
                    DTieModel * model = [DTieModel mj_objectWithKeyValues:dict];
                    [self.dataSource addObject:model];
                }
                [self.DtieCollectionView reloadData];
                
                self.start += self.length;
                
            }
        }
        [self.DtieCollectionView.mj_footer endRefreshing];
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        //        [hud hideAnimated:YES];
        //        [MBProgressHUD showTextHUDWithText:@"获取D帖失败" inView:self.view];
        [self.DtieCollectionView.mj_footer endRefreshing];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        //        [hud hideAnimated:YES];
        //        [MBProgressHUD showTextHUDWithText:@"获取D帖失败" inView:self.view];
        [self.DtieCollectionView.mj_footer endRefreshing];
    }];
}

- (void)deleteDtieWithIndexPath:(NSIndexPath *)indexPath
{
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.row];
    
    NSInteger postID = model.postId;
    if (postID == 0) {
        postID = model.cid;
    }
    
    DTieDeleteRequest * request = [[DTieDeleteRequest alloc] initWithPostId:postID];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
    
    [self.dataSource removeObject:model];
    [self.DtieCollectionView deleteItemsAtIndexPaths:@[indexPath]];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.DTieView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kMainBoundsWidth / 2, 360 * scale);
    layout.minimumLineSpacing = 30 * scale;
    layout.minimumInteritemSpacing = 0;
    
    self.DtieCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.DtieCollectionView registerClass:[DTieHeaderLogoCell class] forCellWithReuseIdentifier:@"DTieHeaderLogoCell"];
    self.DtieCollectionView.backgroundColor = self.view.backgroundColor;
    self.DtieCollectionView.delegate = self;
    self.DtieCollectionView.dataSource = self;
    self.DtieCollectionView.alwaysBounceVertical = YES;
    [self.DTieView addSubview:self.DtieCollectionView];
    [self.DtieCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.DtieCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    self.DtieCollectionView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(getMoreList)];
    
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDidChange:)];
    [self.DtieCollectionView addGestureRecognizer:longPress];
    
    self.seriesView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UICollectionViewFlowLayout * layout2 = [[UICollectionViewFlowLayout alloc] init];
    layout2.itemSize = CGSizeMake(kMainBoundsWidth / 2, 400 * scale);
    layout2.minimumLineSpacing = 0 * scale;
    layout2.minimumInteritemSpacing = 0;
    
    self.seriesCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout2];
    [self.seriesCollectionView registerClass:[NewSeriesCollectionViewCell class] forCellWithReuseIdentifier:@"NewSeriesCollectionViewCell"];
    self.seriesCollectionView.backgroundColor = self.view.backgroundColor;
    self.seriesCollectionView.delegate = self;
    self.seriesCollectionView.dataSource = self;
    self.seriesCollectionView.alwaysBounceVertical = YES;
    [self.seriesView addSubview:self.seriesCollectionView];
    [self.seriesCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.seriesCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getSeriesData)];
    self.seriesCollectionView.contentInset = UIEdgeInsetsMake(0 * scale, 0, 324 * scale, 0);
    
    UILongPressGestureRecognizer * longPress2 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDidChange:)];
    [self.seriesCollectionView addGestureRecognizer:longPress2];
    
    [self.view addSubview:self.DTieView];
    [self.DTieView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((364 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    [self.view addSubview:self.seriesView];
    [self.seriesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((364 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenChooseView)];
    self.addChooseView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.addChooseView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3f];
    [self.addChooseView addGestureRecognizer:tap];
    
    self.leftHandleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.leftHandleButton setImage:[UIImage imageNamed:@"imageChoose"] forState:UIControlStateNormal];
    [self.addChooseView addSubview:self.leftHandleButton];
    self.leftHandleButton.frame = CGRectMake(0, 0, 120 * scale, 120 * scale);
    self.leftHandleButton.center = self.addChooseView.center;
    [self.leftHandleButton addTarget:self action:@selector(leftHandleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.rightHandleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rightHandleButton setImage:[UIImage imageNamed:@"videoChoose"] forState:UIControlStateNormal];
    [self.addChooseView addSubview:self.rightHandleButton];
    self.rightHandleButton.frame = CGRectMake(0, 0, 120 * scale, 120 * scale);
    self.rightHandleButton.center = self.addChooseView.center;
    [self.rightHandleButton addTarget:self action:@selector(rightHandleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.tempAddButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.tempAddButton setImage:[UIImage imageNamed:@"addEdit"] forState:UIControlStateNormal];
    [self.addChooseView addSubview:self.tempAddButton];
    self.tempAddButton.frame = CGRectMake(0, 0, 72 * scale, 72 * scale);
    self.tempAddButton.center = self.addChooseView.center;
    [self.tempAddButton addTarget:self action:@selector(hiddenChooseView) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * createSeriesButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"新建系列"];
    createSeriesButton.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [DDViewFactoryTool cornerRadius:24 * scale withView:createSeriesButton];
    createSeriesButton.layer.borderColor = UIColorFromRGB(0xDB5282).CGColor;
    createSeriesButton.layer.borderWidth = 3 * scale;
    [self.seriesView addSubview:createSeriesButton];
    [createSeriesButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.bottom.mas_equalTo(-63 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(144 * scale);
    }];
    [createSeriesButton addTarget:self action:@selector(createSeries) forControlEvents:UIControlEventTouchUpInside];
    
    [self createTopView];
    
    self.pageType = 1;
    [self reloadWithPageType];
}

- (void)createSeries
{
    NewAddSeriesController * add = [[NewAddSeriesController alloc] init];
    [self.navigationController pushViewController:add animated:YES];
}

- (void)leftHandleButtonDidClicked
{
    [self hiddenChooseView];
    if (self.pageType == 1) {
        DTieModel * model = [self.dataSource objectAtIndex:self.handleIndex.row];
        NSInteger postID = model.postId;
        if (postID == 0) {
            postID = model.cid;
        }
        SeriesSelectViewController * select = [[SeriesSelectViewController alloc] initWithPostID:postID seriesSource:self.seriesDataSource];
        [self.navigationController pushViewController:select animated:YES];
    }else{
        
        SeriesModel * model = [self.seriesDataSource objectAtIndex:self.handleIndex.item];
//
//        if (model.stickyFlag == 1) {
//            AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
//            manager.requestSerializer = [AFJSONRequestSerializer serializer];
//            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//
//            NSString * url = [NSString stringWithFormat:@"%@/series/cancelStickySeries", HOSTURL];
//            [manager POST:url parameters:@{@"seriesId":@(model.cid)} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//
//            } progress:^(NSProgress * _Nonnull uploadProgress) {
//
//            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//                [self getSeriesData];
//
//            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//            }];
//        }else{
            AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            
            NSString * url = [NSString stringWithFormat:@"%@/series/stickySeries", HOSTURL];
            [manager POST:url parameters:@{@"seriesId":@(model.cid)} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                [self.seriesDataSource removeObject:model];
                model.stickyFlag = 1;
                [self.seriesDataSource insertObject:model atIndex:0];
                [self.seriesCollectionView reloadData];
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
            }];
//        }
    }
}

- (void)rightHandleButtonDidClicked
{
    [self hiddenChooseView];
    if (self.pageType == 1) {
        [self deleteDtieWithIndexPath:self.handleIndex];
    }else{
        
        SeriesModel * model = [self.seriesDataSource objectAtIndex:self.handleIndex.item];
        AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        NSString * url = [NSString stringWithFormat:@"%@/series/deleteSeries", HOSTURL];
        [manager POST:url parameters:@{@"id":@(model.cid)} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self.seriesDataSource removeObject:model];
            [self.seriesCollectionView reloadData];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
    }
}

- (void)longPressDidChange:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        if (self.pageType == 1) {
            CGPoint point = [longPress locationInView:self.DtieCollectionView];
            NSIndexPath * index = [self.DtieCollectionView indexPathForItemAtPoint:point];
            if (index) {
                [self showChooseViewWithCenter:[longPress locationInView:self.view] handleIndex:index];
            }
        }else{
            CGPoint point = [longPress locationInView:self.seriesCollectionView];
            NSIndexPath * index = [self.seriesCollectionView indexPathForItemAtPoint:point];
            if (index) {
                [self showChooseViewWithCenter:[longPress locationInView:self.view] handleIndex:index];
            }
        }
    }
}

#pragma mark - 添加新的元素
//展示进行选择添加项
- (void)showChooseViewWithCenter:(CGPoint)center handleIndex:(NSIndexPath *)handleIndex;
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
//    UICollectionViewCell * cell = [self.DtieCollectionView cellForItemAtIndexPath:handleIndex];
//    center = [self.view convertPoint:cell.center toView:self.view];
    
    if (self.pageType == 1) {
        [self.leftHandleButton setImage:[UIImage imageNamed:@"jiaruxilie"] forState:UIControlStateNormal];
        [self.rightHandleButton setImage:[UIImage imageNamed:@"shanchutie"] forState:UIControlStateNormal];
    }else{
        [self.leftHandleButton setImage:[UIImage imageNamed:@"xiliezhiding"] forState:UIControlStateNormal];
        [self.rightHandleButton setImage:[UIImage imageNamed:@"shanchuxilie"] forState:UIControlStateNormal];
    }
    
    self.handleIndex = handleIndex;
    
    [self.view addSubview:self.addChooseView];
    [self.addChooseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.leftHandleButton.center = center;
    self.rightHandleButton.center = center;
    self.tempAddButton.center = center;
    
    CGPoint leftCenter = CGPointMake(center.x - 100 * scale, center.y - 100 * scale);
    CGPoint rightCenter = CGPointMake(center.x + 100 * scale, center.y - 100 * scale);
    
    [UIView animateWithDuration:.5f delay:0.f usingSpringWithDamping:.5f initialSpringVelocity:15.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.leftHandleButton.center = leftCenter;
        self.rightHandleButton.center = rightCenter;
        self.addChooseView.alpha = 1;
        self.tempAddButton.transform = CGAffineTransformMakeRotation(M_PI/4.f);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hiddenChooseView
{
    [self.addChooseView removeFromSuperview];
    self.tempAddButton.transform = CGAffineTransformMakeRotation(0);
}

- (void)newDTieDidCreate
{
    [self refreshData];
}

- (void)createTopView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.topView = [[UIView alloc] init];
    self.topView.userInteractionEnabled = YES;
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo((364 + kStatusBarHeight) * scale);
    }];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth, (364 + kStatusBarHeight) * scale);
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
        make.bottom.mas_equalTo(-159 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentLeft];
    titleLabel.text = @"我的";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale - 144 * scale);
    }];
    
    self.searchButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [self.searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [self.searchButton addTarget:self action:@selector(searchButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.searchButton];
    [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-40 * scale);
        make.centerY.mas_equalTo(titleLabel);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    self.mapButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [self.mapButton setImage:[UIImage imageNamed:@"map"] forState:UIControlStateNormal];
    [self.mapButton addTarget:self action:@selector(mapButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.mapButton];
    [self.mapButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.searchButton.mas_left).offset(-20 * scale);
        make.centerY.mas_equalTo(titleLabel);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    CGFloat buttonWidth = kMainBoundsWidth / 2.f;
    self.DTieButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"我的D帖"];
    [self.DTieButton addTarget:self action:@selector(dtieButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.DTieButton];
    [self.DTieButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(144 * scale);
    }];
    
    self.seriesButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:[UIColor whiteColor] title:@"我的系列"];
    [self.seriesButton addTarget:self action:@selector(seriesButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.seriesButton];
    [self.seriesButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(144 * scale);
    }];
    
    UIView * lineView1 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView1.alpha = .5f;
    lineView1.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.topView addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.DTieButton.mas_right);
        make.centerY.mas_equalTo(self.DTieButton);
        make.width.mas_equalTo(3 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadWithPageType
{
    if (self.pageType == 1) {
        self.DTieButton.alpha = 1.f;
        self.seriesButton.alpha = .5f;
        
        self.seriesView.hidden = YES;
        self.DTieView.hidden = NO;
    }else{
        self.DTieButton.alpha = .5f;
        self.seriesButton.alpha = 1.f;
        
        self.seriesView.hidden = NO;
        self.DTieView.hidden = YES;
    }
}

- (void)dtieButtonDidClicked
{
    if (self.pageType != 1) {
        self.pageType = 1;
        [self reloadWithPageType];
    }
}

- (void)seriesButtonDidClicked
{
    if (self.pageType != 2) {
        self.pageType = 2;
        [self reloadWithPageType];
    }
}

- (void)mapButtonDidClicked
{
    DTieMapViewController * map = [[DTieMapViewController alloc] init];
    [self.navigationController pushViewController:map animated:YES];
}

- (void)searchButtonDidClicked
{
    DTieSearchViewController * search = [[DTieSearchViewController alloc] init];
    DDNavigationViewController * na = [[DDNavigationViewController alloc] initWithRootViewController:search];
    [self presentViewController:na animated:YES completion:nil];
    [[DDBackWidow shareWindow] hidden];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.DtieCollectionView) {
        DTieModel * model = [self.dataSource objectAtIndex:indexPath.item];
        
        NSInteger postID = model.postId;
        if (postID == 0) {
            postID = model.cid;
        }
        
        if (model.status == 0) {
            if (model.authorId != [UserManager shareManager].user.cid) {
                
                [MBProgressHUD showTextHUDWithText:@"该帖已被作者变为草稿状态" inView:self.view];
                
                return;
            }
            
            MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在获取草稿" inView:self.view];
            
            DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:postID type:4 start:0 length:10];
            [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                [hud hideAnimated:YES];
                
                if (KIsDictionary(response)) {
                    
                    NSInteger code = [[response objectForKey:@"status"] integerValue];
                    if (code == 4002) {
                        [MBProgressHUD showTextHUDWithText:@"该帖已被作者删除~" inView:self.view];
                        [self.dataSource removeObject:model];
                        [self.DtieCollectionView reloadData];
                        
                        return;
                    }
                    
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
        }else{
            DDCollectionViewController * collection = [[DDCollectionViewController alloc] initWithDataSource:self.dataSource index:indexPath.row];
            [self.navigationController pushViewController:collection animated:YES];
        }
    }else{
        
        SeriesModel * model = [self.seriesDataSource objectAtIndex:indexPath.item];
        
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"获取系列" inView:self.view];
        SeriesDetailRequest * request = [[SeriesDetailRequest alloc] initWithSeriesID:model.cid];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [hud hideAnimated:YES];
            if (KIsDictionary(response)) {
                NSArray * data = [response objectForKey:@"data"];
                if (KIsArray(data)) {
                    NSMutableArray * dataSource = [DTieModel mj_objectArrayWithKeyValuesArray:data];
                    ShowSeriesViewController * show = [[ShowSeriesViewController alloc] initWithData:dataSource series:model];
                    [self.navigationController pushViewController:show animated:YES];
                }
            }
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [MBProgressHUD showTextHUDWithText:@"获取系列信息失败" inView:self.view];
            [hud hideAnimated:YES];
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:self.view];
            [hud hideAnimated:YES];
        }];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.DtieCollectionView) {
        return self.dataSource.count;
    }else{
        return self.seriesDataSource.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.DtieCollectionView) {
        DTieHeaderLogoCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DTieHeaderLogoCell" forIndexPath:indexPath];
        
        DTieModel * model = [self.dataSource objectAtIndex:indexPath.item];
        
        cell.indexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section];
        
        [cell configWithDTieModel:model];
        [cell confiEditEnable:self.isEdit];
        
        return cell;
    }else{
        NewSeriesCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NewSeriesCollectionViewCell" forIndexPath:indexPath];
        
        SeriesModel * model = [self.seriesDataSource objectAtIndex:indexPath.item];
        [cell configWithModel:model];
        
        return cell;
    }
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    
    return _dataSource;
}

- (NSMutableArray *)seriesDataSource
{
    if (!_seriesDataSource) {
        _seriesDataSource = [[NSMutableArray alloc] init];
    }
    return _seriesDataSource;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[DDBackWidow shareWindow] show];
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
