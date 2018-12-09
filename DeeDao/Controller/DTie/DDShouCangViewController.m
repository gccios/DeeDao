//
//  DDShouCangViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/20.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDShouCangViewController.h"
#import "DTieHeaderLogoCell.h"
#import "DTieNewEditViewController.h"
#import "DTieNewEditViewController.h"
#import "QNDDUploadManager.h"
#import "DTieListRequest.h"
#import "MBProgressHUD+DDHUD.h"
#import "DDCollectionViewController.h"
#import <UIImageView+WebCache.h>
#import "SeriesViewController.h"
#import "DTieMapViewController.h"
#import "DTieDetailRequest.h"
#import "DTieSearchViewController.h"
#import "DDNavigationViewController.h"
#import "DTieDeleteRequest.h"
#import "UserManager.h"
#import <MJRefresh.h>
#import "DTieSearchRequest.h"
#import "SeriesSelectViewController.h"
#import "GetSeriesRequest.h"
#import "SeriesModel.h"
#import "DDBackWidow.h"

@interface DDShouCangViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView * DTieManagerView;

@property (nonatomic, strong) UIButton * searchButton;
@property (nonatomic, strong) UIButton * mapButton;
@property (nonatomic, strong) UIButton * seriesButton;

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UICollectionView * collectionView;

@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger length;

@property (nonatomic, strong) UILongPressGestureRecognizer * longPress;

@property (nonatomic, strong) UIView * addChooseView;
@property (nonatomic, strong) UIButton * tempAddButton;
@property (nonatomic, strong) UIButton * leftHandleButton;
@property (nonatomic, strong) UIButton * rightHandleButton;
@property (nonatomic, strong) NSIndexPath * handleIndex;
@property (nonatomic, strong) NSMutableArray * seriesDataSource;
@property (nonatomic, assign) BOOL isEdit;

@end

@implementation DDShouCangViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.seriesDataSource = [[NSMutableArray alloc] init];
    
    self.isEdit = NO;
    
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
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
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
}

- (void)refreshData
{
    //    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:self.view];
    self.start = 0;
    self.length = 10;
    DTieSearchRequest * request = [[DTieSearchRequest alloc] initWithSortType:1 dataSources:2 type:2 pageStart:self.start pageSize:self.length];
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
                [self.collectionView reloadData];
                
                self.start = self.length + 1;
                
            }
        }
        [self.collectionView.mj_header endRefreshing];
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        //        [hud hideAnimated:YES];
        //        [MBProgressHUD showTextHUDWithText:@"获取D帖失败" inView:self.view];
        [self.collectionView.mj_header endRefreshing];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        //        [hud hideAnimated:YES];
        //        [MBProgressHUD showTextHUDWithText:@"获取D帖失败" inView:self.view];
        [self.collectionView.mj_header endRefreshing];
    }];
}

- (void)getMoreList
{
    //    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:self.view];
    
    DTieSearchRequest * request = [[DTieSearchRequest alloc] initWithSortType:1 dataSources:2 type:2 pageStart:self.start pageSize:self.length];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        //        [hud hideAnimated:YES];
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data) && data.count > 0) {
                for (NSDictionary * dict in data) {
                    DTieModel * model = [DTieModel mj_objectWithKeyValues:dict];
                    [self.dataSource addObject:model];
                }
                [self.collectionView reloadData];
                
                self.start += self.length;
                
            }
        }
        [self.collectionView.mj_footer endRefreshing];
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        //        [hud hideAnimated:YES];
        //        [MBProgressHUD showTextHUDWithText:@"获取D帖失败" inView:self.view];
        [self.collectionView.mj_footer endRefreshing];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        //        [hud hideAnimated:YES];
        //        [MBProgressHUD showTextHUDWithText:@"获取D帖失败" inView:self.view];
        [self.collectionView.mj_footer endRefreshing];
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
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kMainBoundsWidth / 2, 360 * scale);
    layout.minimumLineSpacing = 30 * scale;
    layout.minimumInteritemSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView registerClass:[DTieHeaderLogoCell class] forCellWithReuseIdentifier:@"DTieHeaderLogoCell"];
    self.collectionView.backgroundColor = self.view.backgroundColor;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.alwaysBounceVertical = YES;
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    self.collectionView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(getMoreList)];
    
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDidChange:)];
    [self.collectionView addGestureRecognizer:self.longPress];
    [self createTopView];
    
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
}

- (void)hiddenChooseView
{
    [self.addChooseView removeFromSuperview];
    self.tempAddButton.transform = CGAffineTransformMakeRotation(0);
}

- (void)leftHandleButtonDidClicked
{
    [self hiddenChooseView];
    DTieModel * model = [self.dataSource objectAtIndex:self.handleIndex.row];
    NSInteger postID = model.postId;
    if (postID == 0) {
        postID = model.cid;
    }
    SeriesSelectViewController * select = [[SeriesSelectViewController alloc] initWithPostID:postID seriesSource:self.seriesDataSource];
    [self.navigationController pushViewController:select animated:YES];
}

- (void)rightHandleButtonDidClicked
{
    [self hiddenChooseView];
    [self deleteDtieWithIndexPath:self.handleIndex];
}

- (void)longPressDidChange:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [longPress locationInView:self.collectionView];
        NSIndexPath * index = [self.collectionView indexPathForItemAtPoint:point];
        if (index) {
            [self showChooseViewWithCenter:[longPress locationInView:self.view] handleIndex:index];
        }
    }
//    if (longPress.state == UIGestureRecognizerStateBegan) {
//        self.isEdit = !self.isEdit;
//        [self.collectionView reloadData];
//    }
}

#pragma mark - 添加新的元素
//展示进行选择添加项
- (void)showChooseViewWithCenter:(CGPoint)center handleIndex:(NSIndexPath *)handleIndex;
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    //    UICollectionViewCell * cell = [self.DtieCollectionView cellForItemAtIndexPath:handleIndex];
    //    center = [self.view convertPoint:cell.center toView:self.view];
    
    [self.leftHandleButton setImage:[UIImage imageNamed:@"jiaruxilie"] forState:UIControlStateNormal];
    [self.rightHandleButton setImage:[UIImage imageNamed:@"quxiaoshoucang"] forState:UIControlStateNormal];
    
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
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentLeft];
    titleLabel.text = DDLocalizedString(@"My Collections");
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
    
    UIButton * searchButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:searchButton];
    [searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-40 * scale);
        make.centerY.mas_equalTo(titleLabel);
        make.width.height.mas_equalTo(100 * scale);
    }];
}

- (void)searchButtonDidClicked
{
    DTieSearchViewController * search = [[DTieSearchViewController alloc] init];
    DDNavigationViewController * na = [[DDNavigationViewController alloc] initWithRootViewController:search];
    [self presentViewController:na animated:YES completion:nil];
    [[DDBackWidow shareWindow] hidden];
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.item];
    
    if (model.status == 0) {
        if (model.authorId != [UserManager shareManager].user.cid) {
            
            [MBProgressHUD showTextHUDWithText:@"该帖已经下线~" inView:self.view];
            
            return;
        }
        
        
//        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在获取草稿" inView:self.view];
//
//        DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:model.postId type:4 start:0 length:10];
//        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
//            [hud hideAnimated:YES];
//
//            if (KIsDictionary(response)) {
//                NSDictionary * data = [response objectForKey:@"data"];
//                if (KIsDictionary(data)) {
//                    DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
//                    dtieModel.postId = model.postId;
//                    DTieNewEditViewController * edit = [[DTieNewEditViewController alloc] initWithDtieModel:dtieModel];
//                    [self.navigationController pushViewController:edit animated:YES];
//                }
//            }
//        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
//            [hud hideAnimated:YES];
//        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
//            [hud hideAnimated:YES];
//        }];
    }else{
        
    }
    DDCollectionViewController * collection = [[DDCollectionViewController alloc] initWithDataSource:self.dataSource index:indexPath.row];
    [self.navigationController pushViewController:collection animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DTieHeaderLogoCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DTieHeaderLogoCell" forIndexPath:indexPath];
    
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.item];
    
    cell.indexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section];
    
    [cell configWithDTieModel:model];
    [cell confiEditEnable:self.isEdit];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(cell) weakCell = cell;
    cell.deleteButtonHandle = ^{
        NSIndexPath * indexPath = [weakSelf.collectionView indexPathForCell:weakCell];
        [weakSelf deleteDtieWithIndexPath:indexPath];
    };
    
    return cell;
}

//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
//{
//    if (scrollView == self.collectionView) {
//        CGFloat contentY = scrollView.contentOffset.y;
//        CGFloat height = self.DTieManagerView.frame.size.height;
//        if (contentY <= -height) {
//            [scrollView setContentOffset:CGPointMake(0, -height) animated:YES];
//        }
//    }
//}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    
    return _dataSource;
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
