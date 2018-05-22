//
//  DTieMapViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieMapViewController.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import "DDLocationManager.h"
#import "DTieSearchRequest.h"
#import "DDTool.h"
#import "DTieModel.h"
#import <UIImageView+WebCache.h>
#import "DDCollectionViewController.h"

@interface DTieMapViewController ()<BMKMapViewDelegate>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) BMKMapView * mapView;

@property (nonatomic, strong) NSMutableArray * mapSource;
@property (nonatomic, strong) NSMutableArray * pointArray;

@property (nonatomic, assign) BOOL isFirst;

@end

@implementation DTieMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isFirst = YES;
    
    [self createViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserLocation) name:DDUserLocationDidUpdateNotification object:nil];
    [[DDLocationManager shareManager] startLocationService];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    [self.view addSubview:self.mapView];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.mapView.delegate = self;
    
    [self createTopView];
}

- (void)updateUserLocation
{
    [self.mapView updateLocationData:[DDLocationManager shareManager].userLocation];
    
    if (self.isFirst) {
        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake([DDLocationManager shareManager].userLocation.location.coordinate, BMKCoordinateSpanMake(.005, .005));
        BMKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
        [self.mapView setRegion:adjustedRegion animated:YES];
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
    DTieSearchRequest * request = [[DTieSearchRequest alloc] initWithKeyWord:@"" lat1:leftUpLati lng1:leftUpLong lat2:rightDownLati lng2:rightDownLong startDate:[DDTool DDGetDoubleTimeWithDisYear:-1 month:0 day:0] endDate:[DDTool getTimeCurrentWithDouble] sortType:2 dataSources:3 type:1 pageStart:0 pageSize:100];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                [self.mapSource removeAllObjects];
                [self.pointArray removeAllObjects];
                for (NSDictionary * dict in data) {
                    DTieModel * model = [DTieModel mj_objectWithKeyValues:dict];
                    [self.mapSource addObject:model];
                    
                    BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc] init];
                    annotation.coordinate = CLLocationCoordinate2DMake(model.sceneAddressLat, model.sceneAddressLng);
                    [self.pointArray addObject:annotation];
                }
                [self.mapView addAnnotations:self.pointArray];
            }
        }
        [self meterDistance];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)meterDistance
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        BMKPointAnnotation * resultPoint;
        CLLocationDistance mostMeters = 0;
        BMKMapPoint userPoint = BMKMapPointForCoordinate([DDLocationManager shareManager].userLocation.location.coordinate);
        
        for (BMKPointAnnotation * annotation in self.pointArray) {
            BMKMapPoint point = BMKMapPointForCoordinate(annotation.coordinate);
            
            CLLocationDistance distance = BMKMetersBetweenMapPoints(userPoint, point);
            if (distance > mostMeters) {
                mostMeters = distance;
                resultPoint = annotation;
            }
        }
        
        CLLocationDegrees lng = fabs([DDLocationManager shareManager].userLocation.location.coordinate.longitude - resultPoint.coordinate.longitude);
        CLLocationDegrees lat = fabs([DDLocationManager shareManager].userLocation.location.coordinate.latitude - resultPoint.coordinate.latitude);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake([DDLocationManager shareManager].userLocation.location.coordinate, BMKCoordinateSpanMake(lat * 2.3, lng * 2.3));
            BMKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
            [self.mapView setRegion:adjustedRegion animated:YES];
        });
        
    });
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    BMKAnnotationView * view = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BMKAnnotationView"];
    view.annotation = annotation;
    view.image = [UIImage imageNamed:@"touxiangkuang"];
    view.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:[UIView new]];
    
    NSInteger index = [self.pointArray indexOfObject:annotation];
    DTieModel * model = [self.mapSource objectAtIndex:index];
    
    if ([view viewWithTag:888]) {
        UIImageView * imageView = (UIImageView *)[view viewWithTag:888];
        [imageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
    }else{
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 46, 46)];
        imageView.tag = 888;
        [view addSubview:imageView];
        [DDViewFactoryTool cornerRadius:23 withView:imageView];
        [imageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
    }
    
    return view;
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    if ([self.pointArray containsObject:view.annotation]) {
        NSInteger index = [self.pointArray indexOfObject:view.annotation];
        
        DDCollectionViewController * vc = [[DDCollectionViewController alloc] initWithDataSource:self.mapSource index:index];
        [self.navigationController pushViewController:vc animated:YES];
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
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentCenter];
    titleLabel.text = @"D贴";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:NO];
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

- (NSMutableArray *)mapSource
{
    if (!_mapSource) {
        _mapSource = [NSMutableArray new];
    }
    return _mapSource;
}

- (NSMutableArray *)pointArray
{
    if (!_pointArray) {
        _pointArray = [[NSMutableArray alloc] init];
    }
    return _pointArray;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DDUserLocationDidUpdateNotification object:nil];
    self.mapView.delegate = nil;
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
