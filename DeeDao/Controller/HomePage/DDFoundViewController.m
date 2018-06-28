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
#import <BaiduMapAPI_Map/BMKCircleView.h>
#import <BaiduMapAPI_Map/BMKGroundOverlay.h>
#import "DDLocationManager.h"
#import "SCSafariPageController.h"
#import "OnlyMapViewController.h"
#import "DDCollectionViewController.h"
#import "DTieSearchRequest.h"
#import "DDTool.h"
#import "DTieModel.h"
#import <UIImageView+WebCache.h>
#import "DTieFoundEditView.h"
#import "DTieNewEditViewController.h"
#import "MBProgressHUD+DDHUD.h"
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface DDFoundViewController () <BMKMapViewDelegate, SCSafariPageControllerDelegate, SCSafariPageControllerDataSource, OnlyMapViewControllerDelegate, DTieFoundEditViewDelegate>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UILabel * timeLabel;

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

@property (nonatomic, strong) UIView * tipView;
@property (nonatomic, strong) UILabel * tipLabel;

@property (nonatomic, assign) CLLocationCoordinate2D markCoordinate;
@property (nonatomic, strong) BMKCircle * circle;

@property (nonatomic, assign) BOOL isMotion;

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
    
    self.sourceType = 7;
    
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
    //跟随态旋转角度是否生效
    userlocationStyle.isRotateAngleValid = NO;
    //精度圈是否显示
    userlocationStyle.isAccuracyCircleShow = NO;
    userlocationStyle.locationViewOffsetX = 0;//定位偏移量（经度）
    userlocationStyle.locationViewOffsetY = 0;//定位偏移量（纬度）
    userlocationStyle.locationViewImgName = @"currentLocation";
    [self.mapView updateLocationViewWithParam:userlocationStyle];
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = BMKUserTrackingModeNone;
    self.mapView.buildingsEnabled = NO;
    
    [self.view addSubview:self.mapView];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
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
    
    [self updateUserLocation];
    [self requestMapViewLocations];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserLocation) name:DDUserLocationDidUpdateNotification object:nil];
    
    self.safariPageController = [[SCSafariPageController alloc] init];
    self.safariPageController.canRemoveOnSwipe = NO;
    [self.safariPageController setDataSource:self];
    [self.safariPageController setDelegate:self];
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"mapChooseBG" ofType:@"jpeg"];
    if (isEmptyString(path)) {
        self.safariPageController.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3f];
    }else{
        UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:[UIScreen mainScreen].bounds contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageWithContentsOfFile:path]];
        [self.safariPageController.view insertSubview:imageView atIndex:0];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    
    CGFloat buttonWidth = 100 * scale;
    self.sourceButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"我的"];
    self.sourceButton.backgroundColor = UIColorFromRGB(0xdb6283);
    [self.sourceButton addTarget:self action:@selector(sourceButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sourceButton];
    [self.sourceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.bottom.mas_equalTo(-40 * scale);
        make.width.height.mas_equalTo(buttonWidth);
    }];
    self.sourceButton.layer.cornerRadius = buttonWidth / 2.f;
    self.sourceButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.sourceButton.layer.shadowOpacity = .5f;
    self.sourceButton.layer.shadowOffset = CGSizeMake(0, 10 * scale);
    self.sourceButton.layer.shadowRadius = 10 * scale;
    
    self.timeButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"年"];
    self.timeButton.backgroundColor = UIColorFromRGB(0xdb6283);
    [self.timeButton addTarget:self action:@selector(timeButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.timeButton];
    [self.timeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.bottom.mas_equalTo(self.sourceButton.mas_top).offset(-30 * scale);
        make.width.height.mas_equalTo(buttonWidth);
    }];
    self.timeButton.layer.cornerRadius = buttonWidth / 2.f;
    self.timeButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.timeButton.layer.shadowOpacity = .5f;
    self.timeButton.layer.shadowOffset = CGSizeMake(0, 10 * scale);
    self.timeButton.layer.shadowRadius = 10 * scale;
    
    self.backLocationButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [self.backLocationButton setImage:[UIImage imageNamed:@"backLocation"] forState:UIControlStateNormal];
    [self.backLocationButton addTarget:self action:@selector(backLocationButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backLocationButton];
    [self.backLocationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20 * scale);
        make.bottom.mas_equalTo(self.timeButton.mas_top).offset(-25 * scale);
        make.width.height.mas_equalTo(120 * scale);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestMapViewLocations) name:DTieDidCreateNewNotification object:nil];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(54 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentCenter];
    self.timeLabel.backgroundColor = UIColorFromRGB(0xdb6283);
    [self.view addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale + 60 * scale);
        make.width.mas_equalTo(250 * scale);
        make.height.mas_equalTo(90 * scale);
    }];
    self.timeLabel.text = [NSString stringWithFormat:@"%ld年", self.year];
    self.timeLabel.layer.cornerRadius = 12 * scale;
    self.timeLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.timeLabel.layer.shadowOpacity = .5f;
    self.timeLabel.layer.shadowOffset = CGSizeMake(0, 10 * scale);
    self.timeLabel.layer.shadowRadius = 10 * scale;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showTipWithText:@"摇一摇以刷新附近D帖"];
    });
}

- (void)showTipWithText:(NSString *)text
{
    self.tipView.alpha = 0;
    
    self.tipLabel.text = text;
    [UIView animateWithDuration:.3f animations:^{
        self.tipView.alpha = 1;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.tipView.alpha = 0;
        });
    }];
}

- (void)backLocationButtonDidClicked
{
    BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake([DDLocationManager shareManager].userLocation.location.coordinate, BMKCoordinateSpanMake(.017, .017));
    BMKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
    self.isFirst = NO;
}

- (void)updateUserLocation
{
    [self.mapView updateLocationData:[DDLocationManager shareManager].userLocation];
    
    CLLocationCoordinate2D coors = [DDLocationManager shareManager].userLocation.location.coordinate;
    if (self.circle) {
        [self.mapView removeOverlay:self.circle];
    }
    self.circle = [BMKCircle circleWithCenterCoordinate:coors radius:[DDLocationManager shareManager].distance];
    [self.mapView addOverlay:self.circle];
    
    if (self.isFirst) {
        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake([DDLocationManager shareManager].userLocation.location.coordinate, BMKCoordinateSpanMake(.017, .017));
        BMKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
        [_mapView setRegion:adjustedRegion animated:YES];
        self.isFirst = NO;
    }
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
                [self.mapView removeAnnotations:self.pointArray];
                [self.mapSource removeAllObjects];
                [self.pointArray removeAllObjects];
                
                NSMutableArray * tempPointArray = [[NSMutableArray alloc] init];
                NSMutableArray * tempMapArray = [[NSMutableArray alloc] init];
                
                for (NSDictionary * dict in data) {
                    DTieModel * model = [DTieModel mj_objectWithKeyValues:dict];
                    [tempMapArray addObject:model];
                    
                    BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc] init];
                    annotation.coordinate = CLLocationCoordinate2DMake(model.sceneAddressLat, model.sceneAddressLng);
                    [tempPointArray addObject:annotation];
                }
                [self.mapSource addObjectsFromArray:[[tempMapArray reverseObjectEnumerator] allObjects]];
                [self.pointArray addObjectsFromArray:[[tempPointArray reverseObjectEnumerator] allObjects]];
                [self.mapView addAnnotations:self.pointArray];
//                [self meterDistance];
            }
        }
        
        if (self.isMotion) {
            [MBProgressHUD showTextHUDWithText:@"刷新成功" inView:self.view];
            self.isMotion = NO;
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        self.isMotion = NO;
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        self.isMotion = NO;
        
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
    
    DTieModel * model = [[DTieModel alloc] init];
    model.postSummary = view.titleTextField.text;
    model.sceneAddress = location;
    model.sceneAddressLat = self.markCoordinate.latitude;
    model.sceneAddressLng = self.markCoordinate.longitude;
    
    DTieNewEditViewController * edit = [[DTieNewEditViewController alloc] initWithDtieModel:model];
    [view removeFromSuperview];
    [self.navigationController pushViewController:edit animated:YES];
}

#pragma mark - BMKMapViewDelegate
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self requestMapViewLocations];
}

//- (void)mapview:(BMKMapView *)mapView onLongClick:(CLLocationCoordinate2D)coordinate
//{
//    self.markCoordinate = coordinate;
//    DTieFoundEditView * edit = [[DTieFoundEditView alloc] initWithFrame:CGRectZero coordinate:coordinate];
//    [self.view addSubview:edit];
//    [edit mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(0);
//    }];
//    edit.delegate = self;
//}

- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKCircle class]])
    {
        BMKCircleView* circleView = [[BMKCircleView alloc] initWithOverlay:overlay];
        circleView.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
        circleView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.3];
        circleView.lineWidth = .5f;
        return circleView;
    }
    return nil;
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
        
        CGFloat width = view.frame.size.width;
        CGFloat logoWidth = width * 47.5f / 52.f;
        CGFloat origin = (width - logoWidth) / 2;
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(origin, origin, logoWidth, logoWidth)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.tag = 888;
        [view addSubview:imageView];
        [DDViewFactoryTool cornerRadius:logoWidth / 2 withView:imageView];
        [imageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
    }
    
    return view;
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    [mapView deselectAnnotation:view.annotation animated:YES];
    if ([self.pointArray containsObject:view.annotation]) {
        NSInteger index = [self.pointArray indexOfObject:view.annotation];
        
        DTieModel * model = [self.mapSource objectAtIndex:index];
        NSArray * tempArray = [[self.mapSource reverseObjectEnumerator] allObjects];
        index = [tempArray indexOfObject:model];
        
        DDCollectionViewController * vc = [[DDCollectionViewController alloc] initWithDataSource:tempArray index:index];
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
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentLeft];
    titleLabel.text = @"发现";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60.5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
    
//    self.sourceButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
//    [self.sourceButton setImage:[UIImage imageNamed:@"source"] forState:UIControlStateNormal];
//    [self.sourceButton addTarget:self action:@selector(sourceButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.topView addSubview:self.sourceButton];
//    [self.sourceButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(-40 * scale);
//        make.bottom.mas_equalTo(-20 * scale);
//        make.width.height.mas_equalTo(100 * scale);
//    }];
//
//    self.timeButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
//    [self.timeButton setImage:[UIImage imageNamed:@"time"] forState:UIControlStateNormal];
//    [self.timeButton addTarget:self action:@selector(timeButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.topView addSubview:self.timeButton];
//    [self.timeButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(self.sourceButton.mas_left).offset(-30 * scale);
//        make.bottom.mas_equalTo(-20 * scale);
//        make.width.height.mas_equalTo(100 * scale);
//    }];
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
    if (self.sourceType == 7) {
        self.sourceType = 8;
        [self.sourceButton setTitle:@"博主" forState:UIControlStateNormal];
    }else if (self.sourceType == 8) {
        self.sourceType = 6;
        [self.sourceButton setTitle:@"公开" forState:UIControlStateNormal];
    }else{
        self.sourceType = 7;
        [self.sourceButton setTitle:@"我的" forState:UIControlStateNormal];
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
        self.timeLabel.text = [NSString stringWithFormat:@"%ld年", self.year];
        [self.mapView removeAnnotations:self.pointArray];
        [self requestMapViewLocations];
        
    }
}

-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"手机开始摇动");
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);//让手机震动
        self.isMotion = YES;
        [self requestMapViewLocations];
    }
}

- (void) motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    //摇动取消
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    
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

- (UIView *)tipView
{
    if (!_tipView) {
        CGFloat scale = kMainBoundsWidth / 1080.f;
        
        _tipView = [[UIView alloc] initWithFrame:CGRectZero];
        _tipView.backgroundColor = [UIColorFromRGB(0x394249) colorWithAlphaComponent:.8f];
        [self.view addSubview:_tipView];
        [_tipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(25 * scale + (220 + kStatusBarHeight) * scale);
            make.left.mas_equalTo(24 * scale);
            make.right.mas_equalTo(-24 * scale);
            make.height.mas_equalTo(132 * scale);
        }];
        [DDViewFactoryTool cornerRadius:6 * scale withView:_tipView];
        
        UIImageView * tipImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"shake"]];
        [_tipView addSubview:tipImageView];
        [tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(40 * scale);
            make.centerY.mas_equalTo(0);
            make.width.height.mas_equalTo(45 * scale);
        }];
        
        self.tipLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xF8F8F8) alignment:NSTextAlignmentCenter];
        [_tipView addSubview:self.tipLabel];
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.left.mas_equalTo(120 * scale);
            make.right.mas_equalTo(-120 * scale);
        }];
        
        UIImageView * tipAlert = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"alert"]];
        [_tipView addSubview:tipAlert];
        [tipAlert mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-40 * scale);
            make.centerY.mas_equalTo(0);
            make.width.height.mas_equalTo(60*scale);
        }];
        
        _tipView.alpha = 0;
    }
    return _tipView;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DDUserLocationDidUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DTieDidCreateNewNotification object:nil];
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
