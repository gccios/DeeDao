//
//  DDDTieViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDDTieViewController.h"
#import "DTieCollectionViewCell.h"
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
#import <MJRefresh.h>

@interface DDDTieViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

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
@property (nonatomic, assign) BOOL isEdit;

@end

@implementation DDDTieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isEdit = NO;
    self.start = 0;
    self.length = 20;
    
    [self createViews];
    
    [self refreshData];
}

- (void)refreshData
{
    //    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:self.view];
    
    DTieListRequest * request = [[DTieListRequest alloc] initWithStart:0 length:self.length];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        //        [hud hideAnimated:YES];
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                [self.dataSource removeAllObjects];
                DTieModel * firstModel = [[DTieModel alloc] init];
                firstModel.dTieType = DTieType_Add;
                [self.dataSource addObject:firstModel];
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
        //        [MBProgressHUD showTextHUDWithText:@"获取D贴失败" inView:self.view];
        [self.collectionView.mj_header endRefreshing];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        //        [hud hideAnimated:YES];
        //        [MBProgressHUD showTextHUDWithText:@"获取D贴失败" inView:self.view];
        [self.collectionView.mj_header endRefreshing];
    }];
}

- (void)getMoreList
{
//    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:self.view];
    
    DTieListRequest * request = [[DTieListRequest alloc] initWithStart:self.start length:self.length];
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
//        [MBProgressHUD showTextHUDWithText:@"获取D贴失败" inView:self.view];
        [self.collectionView.mj_footer endRefreshing];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
//        [hud hideAnimated:YES];
//        [MBProgressHUD showTextHUDWithText:@"获取D贴失败" inView:self.view];
        [self.collectionView.mj_footer endRefreshing];
    }];
}

- (void)deleteDtieWithIndexPath:(NSIndexPath *)indexPath
{
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.row];
    
    DTieDeleteRequest * request = [[DTieDeleteRequest alloc] initWithPostId:model.postId];
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
    [self.collectionView registerClass:[DTieCollectionViewCell class] forCellWithReuseIdentifier:@"DTieCollectionViewCell"];
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
    
//    /*
//     D贴顶部下拉资源管理
//     */
//    CGFloat managerViewHeight = 288 * scale;
//    self.DTieManagerView = [[UIView alloc] initWithFrame:CGRectMake(0, -managerViewHeight, kMainBoundsWidth, managerViewHeight)];
//    self.DTieManagerView.backgroundColor = UIColorFromRGB(0xFFFFFF);
//
//    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(managerViewDidClicked)];
//    tap.numberOfTapsRequired = 1;
//    [self.collectionView.panGestureRecognizer requireGestureRecognizerToFail:tap];
//    [self.DTieManagerView addGestureRecognizer:tap];
//
//    [self.collectionView addSubview:self.DTieManagerView];
//
//    UIImageView * managerImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"sourceManager"]];
//    [self.DTieManagerView addSubview:managerImageView];
//    [managerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.height.mas_equalTo(144 * scale);
//        make.centerY.mas_equalTo(0);
//        make.left.mas_equalTo(263 * scale);
//    }];
//
//    UILabel * managerTitleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
//    managerTitleLabel.text = @"D贴素材管理";
//    [self.DTieManagerView addSubview:managerTitleLabel];
//    [managerTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(-50 * scale / 2);
//        make.left.mas_equalTo(managerImageView.mas_right).offset(24 * scale);
//        make.height.mas_equalTo(50 * scale);
//    }];
//
//    UILabel * managerSubtitleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
//    managerSubtitleLabel.text = @"展开所有D贴照片和视频";
//    [self.DTieManagerView addSubview:managerSubtitleLabel];
//    [managerSubtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(managerTitleLabel.mas_bottom).offset(10 * scale);
//        make.left.mas_equalTo(managerImageView.mas_right).offset(24 * scale);
//        make.height.mas_equalTo(36 * scale);
//    }];
//
    [self createTopView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDTieDidCreate) name:DTieDidCreateNewNotification object:nil];
}

- (void)longPressDidChange:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        self.isEdit = !self.isEdit;
        [self.collectionView reloadData];
    }
}

- (void)newDTieDidCreate
{
//    DTieModel * model = notification.object;
//
//    [self.dataSource insertObject:model atIndex:1];
//    [self.collectionView reloadData];
    
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
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentCenter];
    titleLabel.text = @"我的D贴";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60.5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
    
    self.searchButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [self.searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [self.searchButton addTarget:self action:@selector(searchButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.searchButton];
    [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-40 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    self.mapButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [self.mapButton setImage:[UIImage imageNamed:@"map"] forState:UIControlStateNormal];
    [self.mapButton addTarget:self action:@selector(mapButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.mapButton];
    [self.mapButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.searchButton.mas_left).offset(-20 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
//    self.seriesButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
//    [self.seriesButton setImage:[UIImage imageNamed:@"series"] forState:UIControlStateNormal];
//    [self.seriesButton addTarget:self action:@selector(seriesButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.topView addSubview:self.seriesButton];
//    [self.seriesButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(self.mapButton.mas_left).offset(-20 * scale);
//        make.bottom.mas_equalTo(-20 * scale);
//        make.width.height.mas_equalTo(100 * scale);
//    }];
}

- (void)managerViewDidClicked
{
    NSLog(@"下拉资源管理");
}

- (void)seriesButtonDidClicked
{
    SeriesViewController * series = [[SeriesViewController alloc] init];
    [self.navigationController pushViewController:series animated:YES];
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
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.item];
    switch (model.dTieType) {
        case DTieType_Add:
        {
            DTieNewEditViewController * edit = [[DTieNewEditViewController alloc] init];
            [self.navigationController pushViewController:edit animated:YES];
        }
            break;
            
        case DTieType_Edit:
        {
            MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在获取草稿" inView:self.view];
            
            DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:model.postId type:4 start:0 length:10];
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
        }
            break;
            
        default:
        {
            NSMutableArray * array = [[NSMutableArray alloc] initWithArray:self.dataSource];
            [array removeObjectAtIndex:0];
            DDCollectionViewController * collection = [[DDCollectionViewController alloc] initWithDataSource:array index:indexPath.row - 1];
            [self.navigationController pushViewController:collection animated:YES];
        }
            break;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DTieCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DTieCollectionViewCell" forIndexPath:indexPath];
    
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.item];
    
    cell.indexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section];
    
    [cell configWithDTieModel:model];
    [cell confiEditEnable:self.isEdit];
    if (indexPath.row == 0) {
        [cell confiEditEnable:NO];
    }
    
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
        
        DTieModel * model = [[DTieModel alloc] init];
        model.dTieType = DTieType_Add;
        [_dataSource addObject:model];
        
    }
    
    return _dataSource;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DTieDidCreateNewNotification object:nil];
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
