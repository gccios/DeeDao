//
//  DDFoundViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDFoundViewController.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import "DDLocationManager.h"
#import "SCSafariPageController.h"
#import "OnlyMapViewController.h"
#import "DDCollectionViewController.h"
#import "DTieSearchRequest.h"
#import "DDTool.h"
#import "DTieModel.h"
#import <UIImageView+WebCache.h>
#import "DTieFoundEditView.h"
#import "DTieEditViewController.h"
#import "MBProgressHUD+DDHUD.h"

@interface DDFoundViewController () <BMKMapViewDelegate, SCSafariPageControllerDelegate, SCSafariPageControllerDataSource, OnlyMapViewControllerDelegate, DTieFoundEditViewDelegate>

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UIButton * sourceButton;
@property (nonatomic, strong) UIButton * timeButton;

@property (nonatomic, strong) BMKMapView * mapView;
@property (nonatomic, assign) BOOL isFirst;

@property (nonatomic, strong) SCSafariPageController * safariPageController;
@property (nonatomic, strong) NSMutableArray * mapVCSource;

@property (nonatomic, assign) NSInteger sourceType;

@property (nonatomic, strong) NSMutableArray * mapSource;
@property (nonatomic, strong) NSMutableArray * pointArray;

@property (nonatomic, assign) NSInteger year;

@property (nonatomic, strong) UIButton * backLocationButton;

@end

@implementation DDFoundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    // 获取当前日期
    NSDate* dt = [NSDate date];
    // 定义一个时间字段的旗标，指定将会获取指定年、月、日、时、分、秒的信息
    unsigned unitFlags = NSCalendarUnitYear |
    NSCalendarUnitMonth |  NSCalendarUnitDay;
    // 获取不同时间字段的信息
    NSDateComponents* comp = [gregorian components: unitFlags
                                          fromDate:dt];
    self.year = comp.year;
    
    self.isFirst = YES;
    // Do any additional setup after loading the view.
    
    self.sourceType = 6;
    
    [self creatViews];
    [self creatTopView];
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
    self.mapView.userTrackingMode = BMKUserTrackingModeFollow;
    
    [self.view addSubview:self.mapView];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    if ([DDLocationManager shareManager].userLocation) {
        [self updateUserLocation];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserLocation) name:DDUserLocationDidUpdateNotification object:nil];
    
    self.safariPageController = [[SCSafariPageController alloc] init];
    self.safariPageController.canRemoveOnSwipe = NO;
    [self.safariPageController setDataSource:self];
    [self.safariPageController setDelegate:self];
    self.safariPageController.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3f];
    
    self.backLocationButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [self.backLocationButton setImage:[UIImage imageNamed:@"backLocation"] forState:UIControlStateNormal];
    [self.backLocationButton addTarget:self action:@selector(backLocationButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backLocationButton];
    [self.backLocationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.bottom.mas_equalTo(-60 * scale);
        make.width.height.mas_equalTo(120 * scale);
    }];
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
        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake([DDLocationManager shareManager].userLocation.location.coordinate, BMKCoordinateSpanMake(.005, .005));
        BMKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
        [_mapView setRegion:adjustedRegion animated:YES];
        self.isFirst = NO;
    }
    
    [self requestMapViewLocations];
}

- (void)requestMapViewLocations
{
    [DTieSearchRequest cancelRequest];
    
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
    
    DTieSearchRequest * request = [[DTieSearchRequest alloc] initWithKeyWord:@"" lat1:leftUpLati lng1:leftUpLong lat2:rightDownLati lng2:rightDownLong startDate:[DDTool DDGetDoubleWithYear:self.year mouth:0 day:0] endDate:[DDTool DDGetDoubleWithYear:self.year+1 mouth:0 day:0] sortType:2 dataSources:self.sourceType type:1 pageStart:0 pageSize:100];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data) && data.count > 0) {
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
                [self meterDistance];
            }
        }
        
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

- (void)DTieFoundEditViewBeginEidt:(DTieFoundEditView *)view
{
    NSString * location = @"";
    if (!isEmptyString(view.locationLabel.text)) {
        location = [view.locationLabel.text componentsSeparatedByString:@"\n"].lastObject;
    }
    
    DTieEditViewController * edit = [[DTieEditViewController alloc] initWithTitle:view.titleTextField.text address:location];
    [view removeFromSuperview];
    [self.navigationController pushViewController:edit animated:YES];
}

#pragma mark - BMKMapViewDelegate
- (void)mapview:(BMKMapView *)mapView onLongClick:(CLLocationCoordinate2D)coordinate
{
    DTieFoundEditView * edit = [[DTieFoundEditView alloc] initWithFrame:CGRectZero coordinate:coordinate];
    [self.view addSubview:edit];
    [edit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    edit.delegate = self;
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

- (void)creatTopView
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
    titleLabel.text = @"发现";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60.5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
    
    self.sourceButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [self.sourceButton setImage:[UIImage imageNamed:@"source"] forState:UIControlStateNormal];
    [self.sourceButton addTarget:self action:@selector(sourceButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.sourceButton];
    [self.sourceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-40 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    self.timeButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [self.timeButton setImage:[UIImage imageNamed:@"time"] forState:UIControlStateNormal];
    [self.timeButton addTarget:self action:@selector(timeButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.timeButton];
    [self.timeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.sourceButton.mas_left).offset(-30 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
}

- (void)timeButtonDidClicked
{
    UIView * tempView = [self.view snapshotViewAfterScreenUpdates:NO];
    [self.mapVCSource makeObjectsPerformSelector:@selector(addOnlyMapWith:) withObject:tempView];
    
    [self.view addSubview:self.safariPageController.view];
    [self.safariPageController.view setFrame:self.view.bounds];
    [self.safariPageController didMoveToParentViewController:self];
    [self.safariPageController zoomOutAnimated:YES completion:nil];
}

- (void)sourceButtonDidClicked
{
    if (self.sourceType == 3) {
        self.sourceType = 6;
    }else{
        self.sourceType++;
        if (self.sourceType > 6) {
            self.sourceType = 1;
        }
    }
    
    
    if (self.sourceType == 1) {
        [MBProgressHUD showTextHUDWithText:@"切换至自己的帖子" inView:self.view];
    }else if (self.sourceType == 2){
        [MBProgressHUD showTextHUDWithText:@"切换至收藏的帖子" inView:self.view];
    }else if (self.sourceType == 3){
        [MBProgressHUD showTextHUDWithText:@"切换至自己+收藏的帖子" inView:self.view];
    }else{
        [MBProgressHUD showTextHUDWithText:@"切换至公开帖" inView:self.view];
    }
    
    [self.mapView removeAnnotations:self.pointArray];
    [self requestMapViewLocations];
}

- (NSUInteger)numberOfPagesInPageController:(SCSafariPageController *)pageController
{
    return self.mapVCSource.count;
}

- (UIViewController *)pageController:(SCSafariPageController *)pageController viewControllerForPageAtIndex:(NSUInteger)index
{
    return [self.mapVCSource objectAtIndex:index];
}

- (void)viewControllerDidReceiveTap:(OnlyMapViewController *)viewController
{
    if(![self.safariPageController isZoomedOut]) {
        return;
    }
    
    NSUInteger pageIndex = [self.mapVCSource indexOfObject:viewController];
    
    [self.safariPageController zoomIntoPageAtIndex:pageIndex animated:YES completion:^{
        [self.safariPageController removeFromParentViewController];
        [self.safariPageController.view removeFromSuperview];
    }];
    
    if (self.year != viewController.year) {
        self.year = viewController.year;
        [self.mapView removeAnnotations:self.pointArray];
        [self requestMapViewLocations];
        
    }
}

#pragma mark - getter
- (NSMutableArray *)mapVCSource
{
    if (!_mapVCSource) {
        _mapVCSource = [[NSMutableArray alloc] init];
        
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        // 获取当前日期
        NSDate* dt = [NSDate date];
        // 定义一个时间字段的旗标，指定将会获取指定年、月、日、时、分、秒的信息
        unsigned unitFlags = NSCalendarUnitYear |
        NSCalendarUnitMonth |  NSCalendarUnitDay;
        // 获取不同时间字段的信息
        NSDateComponents* comp = [gregorian components: unitFlags
                                              fromDate:dt];
        NSInteger year = comp.year;
        
        for (NSInteger i = 0; i < 50; i++) {
            OnlyMapViewController * map = [[OnlyMapViewController alloc] init];
            map.year = year - i;
            map.delegate = self;
            [_mapVCSource addObject:map];
        }
    }
    return _mapVCSource;
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
