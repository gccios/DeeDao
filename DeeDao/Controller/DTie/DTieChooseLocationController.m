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

@interface DTieChooseLocationController () <BMKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, BMKPoiSearchDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) BMKMapView * mapView;
@property (nonatomic, strong) BMKPoiSearch * poiSearch;
//@property (nonatomic, strong) BMKGeoCodeSearch *geocodesearch;
@property (nonatomic, assign) BOOL isFirst;

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, copy) NSString * tagTitle;

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSArray * tagSource;
@property (nonatomic, strong) UIButton * backLocationButton;
@property (nonatomic, strong) UITextField * textField;

@end

@implementation DTieChooseLocationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isFirst = YES;
    // Do any additional setup after loading the view.
    [self creatViews];
    [self createTopView];
    self.tagTitle = @"美食";
    self.tagSource = @[@"美食", @"景点", @"酒店", @"生活", @"购物", @"运动", @"娱乐", @"自然地物"];
}

- (void)creatViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.mapView = [[BMKMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.mapView.delegate = self;
    
    //设置定位图层自定义样式
    BMKLocationViewDisplayParam *userlocationStyle = [[BMKLocationViewDisplayParam alloc] init];
    //精度圈是否显示
    userlocationStyle.isRotateAngleValid = YES;
    //跟随态旋转角度是否生效
    userlocationStyle.isAccuracyCircleShow = YES;
    userlocationStyle.locationViewOffsetX = 0;//定位偏移量（经度）
    userlocationStyle.locationViewOffsetY = 0;//定位偏移量（纬度）
    [self.mapView updateLocationViewWithParam:userlocationStyle];
    self.mapView.showsUserLocation = YES;
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
    
    UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"currentLocation"]];
    [self.mapView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo(90 * scale);
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.tableView.rowHeight = 150 * scale;
    [self.tableView registerClass:[ChooseLocationCell class] forCellReuseIdentifier:@"ChooseLocationCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mapView.mas_bottom).offset(120 * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kMainBoundsWidth / 6, 120 * scale);
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
        make.bottom.mas_equalTo(self.tableView.mas_top);
        make.height.mas_equalTo(120 * scale);
    }];
    
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
    
    //发起检索
    self.poiSearch = [[BMKPoiSearch alloc] init];
    self.poiSearch.delegate = self;
    [self poiSearchWithCoordinate:[DDLocationManager shareManager].userLocation.location.coordinate];
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
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * tagTitle = [self.tagSource objectAtIndex:indexPath.row];
    if (![self.tagTitle isEqualToString:tagTitle]) {
        self.tagTitle = tagTitle;
        [self poiSearchWithCoordinate:self.mapView.centerCoordinate];
    }
}

#pragma mark -- 地图代理
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
//    [self reverseGeoCodeWith:mapView.centerCoordinate];
    [self poiSearchWithCoordinate:mapView.centerCoordinate];
}

- (void)reverseGeoCodeWith:(CLLocationCoordinate2D)coordinate
{
//    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
//    reverseGeocodeSearchOption.reverseGeoPoint = coordinate;
//    [self.geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
}

- (void)poiSearchWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    
    BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc]init];
    option.pageIndex = 0;
    option.pageCapacity = 20;
    option.location = coordinate;
    option.keyword = self.tagTitle;
    [self.poiSearch poiSearchNearBy:option];
}

//实现PoiSearchDeleage处理回调结果
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResultList errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:poiResultList.poiInfoList];
        [self.tableView reloadData];
        
    }
    else if (error == BMK_SEARCH_AMBIGUOUS_KEYWORD){
        //当在设置城市未找到结果，但在其他城市找到结果时，回调建议检索城市列表
        // result.cityList;
        NSLog(@"起始点有歧义");
    } else {
        [MBProgressHUD showTextHUDWithText:@"暂无搜索结果" inView:self.view];
    }
}

//- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
//{
//    [self.dataSource removeAllObjects];
//    [self.dataSource addObjectsFromArray:result.poiList];
//    [self.tableView reloadData];
//}

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
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.topView addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-30 * scale);
        make.left.mas_equalTo(backButton.mas_right).offset(15 * scale);
        make.right.mas_equalTo(-24 * scale);
        make.height.mas_equalTo((100 + kStatusBarHeight) * scale);
    }];
    self.textField.backgroundColor = UIColorFromRGB(0xFAFAFA);
    [DDViewFactoryTool cornerRadius:6 * scale withView:self.textField];
    self.textField.layer.shadowColor = UIColorFromRGB(0x000000).CGColor;
    self.textField.layer.shadowOpacity = .24f;
    self.textField.layer.shadowRadius = 6 * scale;
    self.textField.layer.shadowOffset = CGSizeMake(0, 6 * scale);
    
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
    if (self.textField.isFirstResponder) {
        [self.textField resignFirstResponder];
    }
    
    NSString * tagTitle = self.textField.text;
    if (isEmptyString(tagTitle)) {
        return;
    }
    
    if (![self.tagTitle isEqualToString:tagTitle]) {
        self.tagTitle = tagTitle;
        [self poiSearchWithCoordinate:self.mapView.centerCoordinate];
    }
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
}

- (void)dealloc
{
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
