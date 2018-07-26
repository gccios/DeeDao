//
//  DTieChooseLocationController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/17.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieChooseLocationController.h"
#import "DDTabCollectionViewCell.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import "ChooseLocationCell.h"
#import "MBProgressHUD+DDHUD.h"
#import "DTieCreateLocationView.h"
#import "CreateLocationRequest.h"
#import "GetUserCreateLocationRequest.h"

@interface DTieChooseLocationController () <BMKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, BMKPoiSearchDelegate, UICollectionViewDelegate, UICollectionViewDataSource, BMKGeoCodeSearchDelegate, DTieCreateLocationViewDelegate>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) BMKMapView * mapView;
@property (nonatomic, strong) BMKPoiSearch * poiSearch;
@property (nonatomic, strong) BMKGeoCodeSearch *geocodesearch;
@property (nonatomic, assign) BOOL isFirst;

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, copy) NSString * tagTitle;

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSArray * tagSource;
@property (nonatomic, strong) UIButton * backLocationButton;

@property (nonatomic, strong) UITextField * cityField;
@property (nonatomic, strong) UITextField * textField;

@property (nonatomic, assign) NSInteger searchType;
@property (nonatomic, assign) NSInteger selectIndex;

@property (nonatomic, strong) UIButton * defaultButton;
@property (nonatomic, strong) UIButton * deedaoButton;

@property (nonatomic, weak) DTieCreateLocationView * createLocationView;
@property (nonatomic, assign) BOOL isAddLocation;
@property (nonatomic, assign) CLLocationDegrees lat;
@property (nonatomic, assign) CLLocationDegrees lng;

@end

@implementation DTieChooseLocationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isFirst = YES;
    self.geocodesearch = [[BMKGeoCodeSearch alloc] init];
    self.geocodesearch.delegate = self;
    
    self.poiSearch = [[BMKPoiSearch alloc] init];
    self.poiSearch.delegate = self;
    
    self.selectIndex = 1;
    self.searchType = 3;
    self.tagTitle = @"美食";
    self.tagSource = @[@"全部", @"美食", @"景点", @"酒店", @"生活", @"购物", @"运动", @"娱乐", @"自然地物"];
    // Do any additional setup after loading the view.
    [self creatViews];
    [self createTopView];
}

- (void)creatViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.mapView = [[BMKMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.mapView.delegate = self;
    
//    //设置定位图层自定义样式
//    BMKLocationViewDisplayParam *userlocationStyle = [[BMKLocationViewDisplayParam alloc] init];
//    //精度圈是否显示
//    userlocationStyle.isRotateAngleValid = YES;
//    //跟随态旋转角度是否生效
//    userlocationStyle.isAccuracyCircleShow = YES;
//    userlocationStyle.locationViewOffsetX = 0;//定位偏移量（经度）
//    userlocationStyle.locationViewOffsetY = 0;//定位偏移量（纬度）
//    [self.mapView updateLocationViewWithParam:userlocationStyle];
    self.mapView.showsUserLocation = NO;
    self.mapView.userTrackingMode = BMKUserTrackingModeNone;
    
    [self.view addSubview:self.mapView];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo((kMainBoundsHeight - (220 + kStatusBarHeight) * scale) / 2 - 120 * scale);
    }];
    
    for (UIView * view in self.mapView.subviews) {
        if ([NSStringFromClass([view class]) isEqualToString:@"BMKInternalMapView"]) {
            for (UIView * tempView in view.subviews) {
                if ([tempView isKindOfClass:[UIImageView class]] && tempView.frame.size.width == 66) {
                    tempView.alpha = 0;
                    break;
                }
            }
        }
    }
    
    if (self.startPoi && self.startPoi.pt.latitude != 0) {
        if (self.isFirst) {
            BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(self.startPoi.pt, BMKCoordinateSpanMake(.01, .01));
            BMKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
            [self.mapView setRegion:adjustedRegion animated:YES];
            self.isFirst = NO;
        }
    }
    
    if ([DDLocationManager shareManager].userLocation) {
        [self updateUserLocation];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserLocation) name:DDUserLocationDidUpdateNotification object:nil];
    
//    self.geocodesearch = [[BMKGeoCodeSearch alloc] init];
//    self.geocodesearch.delegate = self;
    
    UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"location"]];
    [self.mapView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo(90 * scale);
    }];
    
    UIView * tabView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:tabView];
    tabView.backgroundColor = [UIColor whiteColor];
    [tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.mapView.mas_bottom);
        make.height.mas_equalTo(120 * scale);
    }];
    
    UIView * tabLineView = [[UIView alloc] initWithFrame:CGRectZero];
    tabLineView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [tabView addSubview:tabLineView];
    [tabLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.height.mas_equalTo(72 * scale);
        make.width.mas_equalTo(3 * scale);
    }];
    self.defaultButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"默认列表"];
    [tabView addSubview:self.defaultButton];
    [self.defaultButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(0);
        make.right.mas_equalTo(tabLineView.mas_left);
    }];
    
    self.deedaoButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"地到标记"];
    [tabView addSubview:self.deedaoButton];
    [self.deedaoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.mas_equalTo(0);
        make.left.mas_equalTo(tabLineView.mas_right);
    }];
    [self.defaultButton addTarget:self action:@selector(tabButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.deedaoButton addTarget:self action:@selector(tabButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kMainBoundsWidth / 5.5, 120 * scale);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView registerClass:[DDTabCollectionViewCell class] forCellWithReuseIdentifier:@"DDTabCollectionViewCell"];
    self.collectionView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(tabView.mas_bottom);
        make.height.mas_equalTo(120 * scale);
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.tableView.rowHeight = 150 * scale;
    [self.tableView registerClass:[ChooseLocationCell class] forCellReuseIdentifier:@"ChooseLocationCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mapView.mas_bottom).offset(240 * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 40 * scale, 0);
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0x333333);
    [self.collectionView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(2 * scale);
    }];
    
    self.backLocationButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [self.backLocationButton setImage:[UIImage imageNamed:@"backLocation"] forState:UIControlStateNormal];
    [self.backLocationButton addTarget:self action:@selector(backLocationButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:self.backLocationButton];
    [self.backLocationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40 * scale);
        make.bottom.mas_equalTo(-30 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    [self updateWithTabButtonStatus];
    
    //发起检索
//    if (self.startPoi && self.startPoi.pt.latitude != 0) {
//        [self reverseGeoCodeWith:self.startPoi.pt];
//    }else{
//        [self reverseGeoCodeWith:[DDLocationManager shareManager].userLocation.location.coordinate];
//    }
    
    UIView * tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 140 * scale)];
    UILabel * footerLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentRight];
    footerLabel.text = @"没有合适的地址？";
    [tableFooterView addSubview:footerLabel];
    [footerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(kMainBoundsWidth / 2);
    }];
    
    UIButton * footerButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"自己标记一个吧！"];
    [tableFooterView addSubview:footerButton];
    [footerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(footerLabel.mas_right);
        make.top.bottom.mas_equalTo(0);
    }];
    [footerButton addTarget:self action:@selector(addLocationButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableFooterView = tableFooterView;
}

- (void)addLocationButtonDidClicked
{
    DTieCreateLocationView * location = [[DTieCreateLocationView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:location];
    [location mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.top.mas_equalTo(self.mapView.mas_bottom);
    }];
    location.delegate = self;
    self.createLocationView = location;
    
    self.isAddLocation = YES;
    self.lat = self.mapView.centerCoordinate.latitude;
    self.lng = self.mapView.centerCoordinate.longitude;
    [self reverseGeoCodeWith:self.mapView.centerCoordinate];
}

#pragma mark - DTieCreateLocationViewDelegate
- (void)DTieCreateLocationDidCancle
{
    self.isAddLocation = NO;
    [self.createLocationView removeFromSuperview];
}

- (void)DTieCreateLocationDidCompleteAddress:(NSString *)address name:(NSString *)name introduce:(NSString *)introduce
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在创建地点" inView:self.view];
    
    CreateLocationRequest * request = [[CreateLocationRequest alloc] initWithAddress:address name:name lat:self.mapView.centerCoordinate.latitude lng:self.mapView.centerCoordinate.longitude remark:introduce];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        self.searchType = 2;
        [self poiSearchWithCoordinate:self.mapView.centerCoordinate];
        [self updateWithTabButtonStatus];
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"创建成功" inView:self.view];
        
        self.isAddLocation = NO;
        [self.createLocationView removeFromSuperview];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"创建失败" inView:self.view];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"创建失败" inView:self.view];
        
    }];
}

- (void)tabButtonDidClicked:(UIButton *)button
{
    if (button == self.defaultButton) {
        [GetUserCreateLocationRequest cancelRequest];
        if (self.selectIndex == 0) {
            self.searchType = 1;
        }else{
            self.searchType = 3;
        }
    }else{
        self.searchType = 2;
    }
    
    [self poiSearchWithCoordinate:self.mapView.centerCoordinate];
    [self updateWithTabButtonStatus];
}

- (void)updateWithTabButtonStatus
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    if (self.searchType == 2) {
        self.deedaoButton.alpha = 1.f;
        self.defaultButton.alpha = .5f;
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mapView.mas_bottom).offset(120 * scale);
        }];
    }else{
        self.deedaoButton.alpha = .5f;
        self.defaultButton.alpha = 1.f;
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mapView.mas_bottom).offset(240 * scale);
        }];
    }
}

- (void)backLocationButtonDidClicked
{
    BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake([DDLocationManager shareManager].userLocation.location.coordinate, BMKCoordinateSpanMake(.005, .005));
    BMKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
    self.isFirst = NO;
}

- (void)updateUserLocation
{
    [self.mapView updateLocationData:[DDLocationManager shareManager].userLocation];
    
    if (self.isFirst) {
        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake([DDLocationManager shareManager].userLocation.location.coordinate, BMKCoordinateSpanMake(.01, .01));
        BMKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
        [self.mapView setRegion:adjustedRegion animated:YES];
        self.isFirst = NO;
    }
}

#pragma maek -- UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tagSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DDTabCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DDTabCollectionViewCell" forIndexPath:indexPath];
    
    [cell configWithTagTitle:self.tagSource[indexPath.row]];
    
    BOOL select = self.selectIndex == indexPath.row;
    [cell configWithSelectStatus:select];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * tagTitle = [self.tagSource objectAtIndex:indexPath.row];
    
    if ([self.tagTitle isEqualToString:tagTitle]) {
        return;
    }
    
    self.tagTitle = tagTitle;
    self.selectIndex = indexPath.row;
    if (self.selectIndex == 0) {
        self.searchType = 1;
    }else{
        self.searchType = 3;
    }
    
    [collectionView reloadData];
    [self poiSearchWithCoordinate:self.mapView.centerCoordinate];
}

#pragma mark -- 地图代理
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.isAddLocation) {
        if (self.lat == self.mapView.centerCoordinate.latitude && self.lng == self.mapView.centerCoordinate.longitude) {
            
        }else{
            self.lat = self.mapView.centerCoordinate.latitude;
            self.lng = self.mapView.centerCoordinate.longitude;
            [self reverseGeoCodeWith:self.mapView.centerCoordinate];
        }
        return;
    }
    
    [self poiSearchWithCoordinate:mapView.centerCoordinate];
}

- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi *)mapPoi
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

- (void)mapView:(BMKMapView *)mapView onClickedBMKOverlayView:(BMKOverlayView *)overlayView
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

#pragma mark ----反向地理编码
- (void)reverseGeoCodeWith:(CLLocationCoordinate2D)coordinate
{
    BMKReverseGeoCodeSearchOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeSearchOption alloc] init];
    reverseGeocodeSearchOption.location = coordinate;
    [self.geocodesearch reverseGeoCode:reverseGeocodeSearchOption];;
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (self.isAddLocation) {
        
        if (self.createLocationView) {
            NSString * address = result.address;
            if (isEmptyString(address)) {
                address = result.sematicDescription;
            }
            [self.createLocationView configAddress:address];
        }
        
        return;
    }
    
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:result.poiList];
    [self.tableView reloadData];
}

- (void)poiSearchWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    
    NSString * keyWord = self.textField.text;
    NSString * cityWord = self.cityField.text;
    
    if (self.searchType == 2) {
        [self requestDeedaoUserLocation];
        return;
    }
    
    if (isEmptyString(cityWord)) {
        
        if (self.searchType == 1 && isEmptyString(keyWord)) {
            [self reverseGeoCodeWith:self.mapView.centerCoordinate];
            return;
        }
        
        BMKPOINearbySearchOption *option = [[BMKPOINearbySearchOption alloc]init];
        option.pageIndex = 0;
        option.pageSize = 20;
        option.location = coordinate;
        option.radius = 100 * 1000;
        
        if (isEmptyString(keyWord)) {
            option.keywords = @[self.tagTitle];
        }else{
            if (self.searchType != 1) {
                option.tags = @[self.tagTitle];
            }
            option.keywords = @[keyWord];
        }
        
        [self.poiSearch poiSearchNearBy:option];
    }else{
        BMKPOICitySearchOption *citySearchOption = [[BMKPOICitySearchOption alloc]init];
        citySearchOption.pageIndex = 0;
        citySearchOption.pageSize = 10;
        citySearchOption.city= cityWord;
        if (isEmptyString(keyWord)) {
            citySearchOption.keyword = self.tagTitle;
        }else{
            if (self.searchType == 1) {
                citySearchOption.tags = @[@"美食"];
            }else{
                citySearchOption.tags = @[self.tagTitle];
            }
            citySearchOption.keyword = keyWord;
        }
        
        [self.poiSearch poiSearchInCity:citySearchOption];
    }
}

- (void)requestDeedaoUserLocation
{
    GetUserCreateLocationRequest * request  = [[GetUserCreateLocationRequest alloc] initWithKeyWord:self.textField.text lat:self.mapView.centerCoordinate.latitude lng:self.mapView.centerCoordinate.longitude];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.dataSource removeAllObjects];
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                NSArray * poiList = [data objectForKey:@"deedaoPointList"];
                for (NSDictionary * info in poiList) {
                    BMKPoiInfo * poi = [[BMKPoiInfo alloc] init];
                    double lat = [[info objectForKey:@"createAddressLat"] doubleValue];
                    double lng = [[info objectForKey:@"createAddressLng"] doubleValue];
                    poi.pt = CLLocationCoordinate2DMake(lat, lng);
                    poi.name = [info objectForKey:@"createBuilding"];
                    poi.address = [info objectForKey:@"createAddress"];
                    poi.detailInfo = [info objectForKey:@"remark"];
                    [self.dataSource addObject:poi];
                }
            }
        }
        [self.tableView reloadData];
        
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

//实现PoiSearchDeleage处理回调结果
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPOISearchResult *)poiResult errorCode:(BMKSearchErrorCode)errorCode
{
    if (errorCode == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:poiResult.poiInfoList];
        [self.tableView reloadData];
        
    }
    else if (errorCode == BMK_SEARCH_AMBIGUOUS_KEYWORD){
        //当在设置城市未找到结果，但在其他城市找到结果时，回调建议检索城市列表
        // result.cityList;
        NSLog(@"起始点有歧义");
    } else {
        [MBProgressHUD showTextHUDWithText:@"暂无搜索结果,您可以到\"地到标记\"中看一下" inView:self.view];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChooseLocationCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ChooseLocationCell" forIndexPath:indexPath];
    
    BMKPoiInfo * poi = [self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = poi.name;
    cell.detailTextLabel.text = poi.address;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    BMKPoiInfo * poi = [self.dataSource objectAtIndex:indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(chooseLocationDidChoose:)]) {
        [self.delegate chooseLocationDidChoose:poi];
    }
    [self.navigationController popViewControllerAnimated:YES];
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
        make.left.mas_equalTo(20 * scale);
        make.bottom.mas_equalTo(-40 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    self.cityField = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.topView addSubview:self.cityField];
    [self.cityField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-30 * scale);
        make.left.mas_equalTo(backButton.mas_right).offset(15 * scale);
        make.width.mas_equalTo(180 * scale);
        make.height.mas_equalTo((100 + kStatusBarHeight) * scale);
    }];
    self.cityField.backgroundColor = UIColorFromRGB(0xFAFAFA);
    [DDViewFactoryTool cornerRadius:6 * scale withView:self.cityField];
    self.cityField.layer.shadowColor = UIColorFromRGB(0x000000).CGColor;
    self.cityField.layer.shadowOpacity = .24f;
    self.cityField.layer.shadowRadius = 6 * scale;
    self.cityField.layer.shadowOffset = CGSizeMake(0, 6 * scale);
    self.cityField.placeholder = @"城市";
    UIView * leftView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20 * scale, 20 * scale)];
    self.cityField.leftView = leftView1;
    self.cityField.leftViewMode = UITextFieldViewModeAlways;
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.topView addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-30 * scale);
        make.left.mas_equalTo(self.cityField.mas_right).offset(15 * scale);
        make.right.mas_equalTo(-24 * scale);
        make.height.mas_equalTo((100 + kStatusBarHeight) * scale);
    }];
    self.textField.backgroundColor = UIColorFromRGB(0xFAFAFA);
    [DDViewFactoryTool cornerRadius:6 * scale withView:self.textField];
    self.textField.layer.shadowColor = UIColorFromRGB(0x000000).CGColor;
    self.textField.layer.shadowOpacity = .24f;
    self.textField.layer.shadowRadius = 6 * scale;
    self.textField.layer.shadowOffset = CGSizeMake(0, 6 * scale);
    self.textField.placeholder = @"关键字";
    
    UIView * leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20 * scale, 20 * scale)];
    self.textField.leftView = leftView;
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    
    UIButton * sendButton = [DDViewFactoryTool createButtonWithFrame:CGRectMake(0, 0, 130 * scale, 72 * scale) font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"搜索"];
    self.textField.rightView = sendButton;
    self.textField.rightViewMode = UITextFieldViewModeAlways;
    [sendButton addTarget:self action:@selector(searchButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchButtonDidClicked
{
    if (self.isAddLocation) {
        if (self.createLocationView) {
            [self DTieCreateLocationDidCancle];
        }
    }
    
    if (self.cityField.isFirstResponder) {
        [self.cityField resignFirstResponder];
    }
    
    if (self.textField.isFirstResponder) {
        [self.textField resignFirstResponder];
    }
    
    [self poiSearchWithCoordinate:self.mapView.centerCoordinate];
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.mapView.delegate = nil;
    self.poiSearch.delegate = nil;
    self.geocodesearch.delegate = nil;
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
