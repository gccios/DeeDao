//
//  DDDTieViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDDTieViewController.h"
#import "DTieCollectionViewCell.h"
#import "DTieEditViewController.h"
#import "QNDDUploadManager.h"
#import "DTieListRequest.h"
#import "MBProgressHUD+DDHUD.h"
#import "DDCollectionViewController.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import "DDLocationManager.h"
#import "DTieSearchRequest.h"
#import "DDTool.h"
#import <UIImageView+WebCache.h>

@interface DDDTieViewController () <UICollectionViewDelegate, UICollectionViewDataSource, BMKMapViewDelegate>

@property (nonatomic, strong) UIView * DTieManagerView;

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UIButton * searchButton;
@property (nonatomic, assign) BOOL isSearch;
@property (nonatomic, strong) UIButton * mapButton;
@property (nonatomic, assign) BOOL isMap;
@property (nonatomic, strong) UIButton * seriesButton;
@property (nonatomic, assign) BOOL isSeries;
@property (nonatomic, strong) UIButton * homeButton;

@property (nonatomic, strong) UICollectionView * collectionView;

@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger length;

@property (nonatomic, strong) BMKMapView * mapView;
@property (nonatomic, strong) NSMutableArray * mapSource;
@property (nonatomic, assign) BOOL isFirst;

@end

@implementation DDDTieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isFirst = YES;
    self.start = 0;
    self.length = 30;
    
    [self createViews];
    
    [self getMoreList];
}

- (void)getMoreList
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:self.view];
    
    DTieListRequest * request = [[DTieListRequest alloc] initWithStart:self.start length:self.length];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                
                for (NSDictionary * dict in data) {
                    DTieModel * model = [DTieModel mj_objectWithKeyValues:dict];
                    [self.dataSource addObject:model];
                }
                [self.collectionView reloadData];
                
                return;
                
            }
        }
        [MBProgressHUD showTextHUDWithText:@"获取D贴失败" inView:self.view];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"获取D贴失败" inView:self.view];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"获取D贴失败" inView:self.view];
        
    }];
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
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    /*
     D贴顶部下拉资源管理
     */
    CGFloat managerViewHeight = 288 * scale;
    self.DTieManagerView = [[UIView alloc] initWithFrame:CGRectMake(0, -managerViewHeight, kMainBoundsWidth, managerViewHeight)];
    self.DTieManagerView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(managerViewDidClicked)];
    tap.numberOfTapsRequired = 1;
    [self.collectionView.panGestureRecognizer requireGestureRecognizerToFail:tap];
    [self.DTieManagerView addGestureRecognizer:tap];
    
    [self.collectionView addSubview:self.DTieManagerView];
    
    UIImageView * managerImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"sourceManager"]];
    [self.DTieManagerView addSubview:managerImageView];
    [managerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(144 * scale);
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(263 * scale);
    }];
    
    UILabel * managerTitleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    managerTitleLabel.text = @"D贴素材管理";
    [self.DTieManagerView addSubview:managerTitleLabel];
    [managerTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(-50 * scale / 2);
        make.left.mas_equalTo(managerImageView.mas_right).offset(24 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    UILabel * managerSubtitleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
    managerSubtitleLabel.text = @"展开所有D贴照片和视频";
    [self.DTieManagerView addSubview:managerSubtitleLabel];
    [managerSubtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(managerTitleLabel.mas_bottom).offset(10 * scale);
        make.left.mas_equalTo(managerImageView.mas_right).offset(24 * scale);
        make.height.mas_equalTo(36 * scale);
    }];
    
    [self createTopView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDTieDidCreate:) name:DTieDidCreateNotification object:nil];
}

- (void)updateUserLocation
{
    [self.mapView updateLocationData:[DDLocationManager shareManager].userLocation];
    
    if (self.isFirst) {
        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake([DDLocationManager shareManager].userLocation.location.coordinate, BMKCoordinateSpanMake(.005, .005));
        BMKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
        [_mapView setRegion:adjustedRegion animated:YES];
        self.isFirst = NO;
    }
    
    [self requestMapViewLocations];
}

- (void)requestMapViewLocations
{
    CGFloat centerLongitude = self.mapView.region.center.longitude;
    CGFloat centerLatitude = self.mapView.region.center.latitude;
    
    //当前屏幕显示范围的经纬度
    CLLocationDegrees pointssLongitudeDelta = self.mapView.region.span.longitudeDelta;
    CLLocationDegrees pointssLatitudeDelta = self.mapView.region.span.latitudeDelta;
    //左上角
    CGFloat leftUpLong = centerLongitude - pointssLongitudeDelta/2.0;
    CGFloat leftUpLati = centerLatitude - pointssLatitudeDelta/2.0;
    //右下角
    CGFloat rightDownLong = centerLongitude + pointssLongitudeDelta/2.0;
    CGFloat rightDownLati = centerLatitude + pointssLatitudeDelta/2.0;
    [self.mapView convertPoint:CGPointZero toCoordinateFromView:self.mapView];
    DTieSearchRequest * request = [[DTieSearchRequest alloc] initWithKeyWord:@"" lat1:leftUpLati lng1:leftUpLong lat2:rightDownLati lng2:rightDownLong startDate:[DDTool DDGetExpectTimeYear:-1 month:0 day:0] endDate:[DDTool DDGetExpectTimeYear:0 month:0 day:0] sortType:2 dataSources:3 type:1 pageStart:0 pageSize:100];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                [self.mapSource removeAllObjects];
                NSMutableArray * pointArray = [NSMutableArray new];
                for (NSDictionary * dict in data) {
                    DTieModel * model = [DTieModel mj_objectWithKeyValues:dict];
                    [self.mapSource addObject:model];
                    
                    BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc] init];
                    annotation.coordinate = CLLocationCoordinate2DMake(model.sceneAddressLat, model.sceneAddressLng);
                    [pointArray addObject:annotation];
                }
                [self.mapView addAnnotations:pointArray];
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    BMKAnnotationView * view = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BMKAnnotationView"];
    view.annotation = annotation;
    view.image = [UIImage imageNamed:@"touxiangkuang"];
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.backgroundColor = [UIColor redColor];
    [view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(2);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(50);
    }];
    [DDViewFactoryTool cornerRadius:25 withView:imageView];
    
    return view;
}

- (void)newDTieDidCreate:(NSNotification *)notification
{
    DTieModel * model = notification.object;
    
    [self.dataSource insertObject:model atIndex:1];
    [self.collectionView reloadData];
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
    titleLabel.text = @"D贴";
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
    
    self.homeButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [self.homeButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [self.homeButton addTarget:self action:@selector(homeButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.homeButton];
    [self.homeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-40 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    self.homeButton.hidden = YES;
    
    self.mapButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [self.mapButton setImage:[UIImage imageNamed:@"map"] forState:UIControlStateNormal];
    [self.mapButton addTarget:self action:@selector(mapButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.mapButton];
    [self.mapButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.searchButton.mas_left).offset(-20 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    self.seriesButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [self.seriesButton setImage:[UIImage imageNamed:@"series"] forState:UIControlStateNormal];
    [self.seriesButton addTarget:self action:@selector(seriesButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.seriesButton];
    [self.seriesButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mapButton.mas_left).offset(-20 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
}

- (void)homeButtonDidClicked
{
    self.homeButton.hidden = YES;
    self.mapButton.hidden = NO;
    self.searchButton.hidden = NO;
    self.seriesButton.hidden = NO;
    if (self.isMap) {
        self.mapView.delegate = nil;
        [self.mapView removeFromSuperview];
    }
}

- (void)managerViewDidClicked
{
    NSLog(@"下拉资源管理");
}

- (void)seriesButtonDidClicked
{
    NSLog(@"系列");
}

- (void)mapButtonDidClicked
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.homeButton.hidden = NO;
    self.mapButton.hidden = YES;
    self.searchButton.hidden = YES;
    self.seriesButton.hidden = YES;
    self.isMap = YES;
    [self.view addSubview:self.mapView];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.mapView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserLocation) name:DDUserLocationDidUpdateNotification object:nil];
    [[DDLocationManager shareManager] startLocationService];
}

- (void)searchButtonDidClicked
{
    NSLog(@"搜索");
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.item];
    switch (model.dTieType) {
        case DTieType_Add:
        {
            DTieEditViewController * edit = [[DTieEditViewController alloc] init];
            [self.navigationController pushViewController:edit animated:YES];
        }
            break;
            
        case DTieType_Edit:
        {
            DTieEditViewController * edit = [[DTieEditViewController alloc] init];
            [self.navigationController pushViewController:edit animated:YES];
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
    
    return cell;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        CGFloat contentY = scrollView.contentOffset.y;
        CGFloat height = self.DTieManagerView.frame.size.height;
        if (contentY <= -height) {
            [scrollView setContentOffset:CGPointMake(0, -height) animated:YES];
        }
    }
}

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

- (NSMutableArray *)mapSource
{
    if (!_mapSource) {
        _mapSource = [NSMutableArray new];
    }
    return _mapSource;
}

- (BMKMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[BMKMapView alloc] init];
        //设置定位图层自定义样式
        BMKLocationViewDisplayParam *userlocationStyle = [[BMKLocationViewDisplayParam alloc] init];
        //精度圈是否显示
        userlocationStyle.isRotateAngleValid = YES;
        //跟随态旋转角度是否生效
        userlocationStyle.isAccuracyCircleShow = YES;
        userlocationStyle.locationViewOffsetX = 0;//定位偏移量（经度）
        userlocationStyle.locationViewOffsetY = 0;//定位偏移量（纬度）
        [_mapView updateLocationViewWithParam:userlocationStyle];
        _mapView.showsUserLocation = YES;
        _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    }
    return _mapView;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DTieDidCreateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DDUserLocationDidUpdateNotification object:nil];
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
