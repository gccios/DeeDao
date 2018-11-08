//
//  DDLocationManager.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/15.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDLocationManager.h"
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import <MapKit/MapKit.h>
#import "JZLocationConverter.h"
#import "UserManager.h"
#import "CheckNotificationRequest.h"
#import "DaoDiAlertView.h"
#import "DDLGSideViewController.h"
#import "DDNotificationViewController.h"
#import <AudioToolbox/AudioToolbox.h>

NSString * const DDUserLocationDidUpdateNotification = @"DDUserLocationDidUpdateNotification";

@interface DDLocationManager () <BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) BMKLocationService * locationService;
@property (nonatomic, strong) BMKGeoCodeSearch *geocodesearch;

@property (nonatomic, strong) CLLocationManager * sysLocationManager;

@end

@implementation DDLocationManager

+ (instancetype)shareManager
{
    static dispatch_once_t once;
    static DDLocationManager * instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self setUpLocationManager];
        [self startSignificantChangeUpdates];
        self.distance = 500;
    }
    return self;
}

#pragma mark - 显著位置更新
- (void)startSignificantChangeUpdates
{
    if (self.sysLocationManager == nil)
        self.sysLocationManager = [[CLLocationManager alloc] init];
    self.sysLocationManager.delegate = self;
    [self.sysLocationManager startMonitoringSignificantLocationChanges];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (![UserManager shareManager].isLogin) {
        return;
    }
    CLLocation * location = locations.firstObject;
    [CheckNotificationRequest cancelRequest];
    CheckNotificationRequest * request = [[CheckNotificationRequest alloc] init];
    [request configLat:location.coordinate.latitude lng:location.coordinate.longitude];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            
            if (data.count == 0) {
                return ;
            }
            
            NSString * title = [data objectForKey:@"remindTitle"];
            NSString * detail = [data objectForKey:@"remindContent"];
            NSInteger remindId = [[data objectForKey:@"remindId"] integerValue];
            
            UIApplicationState state = [UIApplication sharedApplication].applicationState;
            if (state == UIApplicationStateBackground) {
                [self registerLocaltionNotificationWithTitle:title detail:detail remindId:remindId];
            }else{
                DaoDiAlertView * alert = [[DaoDiAlertView alloc] init];
                alert.handleButtonClicked = ^{
                    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                    if ([lg isKindOfClass:[DDLGSideViewController class]]) {
                        if (lg.leftViewShowing) {
                            [lg hideLeftViewAnimated];
                        }
                        UINavigationController * na = (UINavigationController *)lg.rootViewController;
                        if ([na.topViewController isKindOfClass:[DDNotificationViewController class]]) {
                            [na popViewControllerAnimated:NO];
                            DDNotificationViewController * notification = [[DDNotificationViewController alloc] initWithNotificationID:remindId];
                            [na pushViewController:notification animated:YES];
                        }else{
                            DDNotificationViewController * notification = [[DDNotificationViewController alloc] initWithNotificationID:remindId];
                            [na pushViewController:notification animated:YES];
                        }
                    }
                };
                [alert show];
            }
            
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

#pragma mark - 实时位置更新
- (void)setUpLocationManager
{
    self.locationService = [[BMKLocationService alloc] init];
    self.locationService.delegate = self;
    self.locationService.distanceFilter = 10.f;
    self.locationService.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationService.allowsBackgroundLocationUpdates = NO;
    
    self.geocodesearch = [[BMKGeoCodeSearch alloc] init];
    self.geocodesearch.delegate = self;
}

- (void)startLocationService
{
    [self.locationService startUserLocationService];
}

- (void)stopLocationService
{
    [self.locationService stopUserLocationService];
}

#pragma mark ----位置更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    self.userLocation = userLocation;
    [self reverseGeoCodeWith:self.userLocation.location.coordinate];
    
    [self checkNotification];
    
//    [self stopLocationService];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DDUserLocationDidUpdateNotification object:nil];
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
    self.result = result;
}

- (BOOL)postIsCanDazhaohuWith:(DTieModel *)model
{
    BMKMapPoint userPoint = BMKMapPointForCoordinate(self.userLocation.location.coordinate);
    BMKMapPoint point = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(model.sceneAddressLat, model.sceneAddressLng));
    CLLocationDistance distance = BMKMetersBetweenMapPoints(userPoint, point);
    
    if (distance > self.distance) {
        return NO;
    }
    
    return YES;
}

- (BOOL)contentIsCanSeeWith:(DTieModel *)model detailModle:(DTieEditModel *)detailModel
{
    if (detailModel.pFlag == 0) {
        return YES;
    }
    
    if (model.authorId == [UserManager shareManager].user.cid) {
        return YES;
    }
    
    BMKMapPoint userPoint = BMKMapPointForCoordinate(self.userLocation.location.coordinate);
    BMKMapPoint point = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(model.sceneAddressLat, model.sceneAddressLng));
    CLLocationDistance distance = BMKMetersBetweenMapPoints(userPoint, point);
    
    if (distance > self.distance) {
        return NO;
    }
    
    return YES;
}

- (void)mapNavigationToLongitude:(double)longitude latitude:(double)latitude poiName:(NSString *)name withViewController:(UIViewController *)viewController
{
    NSMutableArray *maps = [NSMutableArray array];
    
    //百度地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        NSMutableDictionary *baiduMapDic = [NSMutableDictionary dictionary];
        baiduMapDic[@"title"] = @"百度地图";
        NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=%@&mode=walking&coord_type=gcj02",latitude,longitude,name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        baiduMapDic[@"url"] = urlString;
        [maps addObject:baiduMapDic];
    }
    
    //高德地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        NSMutableDictionary *gaodeMapDic = [NSMutableDictionary dictionary];
        gaodeMapDic[@"title"] = @"高德地图";
        NSString *urlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&poiname=%@&lat=%f&lon=%f&dev=0&style=2",@"DeeDao",name, latitude, longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        gaodeMapDic[@"url"] = urlString;
        [maps addObject:gaodeMapDic];
    }
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {
        NSMutableDictionary *qqMapDic = [NSMutableDictionary dictionary];
        qqMapDic[@"title"] = @"腾讯地图";
        NSString *urlString = [[NSString stringWithFormat:@"qqmap://map/routeplan?from=我的位置&type=walk&tocoord=%f,%f&to=终点&coord_type=1&policy=0",latitude, longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        qqMapDic[@"url"] = urlString;
        [maps addObject:qqMapDic];
    }
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"导航" message:@"请选择您要使用的导航方式" preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSDictionary * mapDict in maps) {
        UIAlertAction * action = [UIAlertAction actionWithTitle:[mapDict objectForKey:@"title"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString * urlStr = [mapDict objectForKey:@"url"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        }];
        [alert addAction:action];
    }
    
    UIAlertAction * appleAction = [UIAlertAction actionWithTitle:@"Apple地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        CLLocationCoordinate2D gps = [JZLocationConverter gcj02ToWgs84:CLLocationCoordinate2DMake(latitude, longitude)];
        
        MKMapItem *currentLoc = [MKMapItem mapItemForCurrentLocation];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:gps addressDictionary:nil]];
        toLocation.name = name;
        NSArray *items = [NSArray arrayWithObjects:currentLoc, toLocation, nil];
        NSDictionary *dic = @{
                              MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking,
                              MKLaunchOptionsMapTypeKey : [NSNumber numberWithInteger:MKMapTypeStandard],
                              MKLaunchOptionsShowsTrafficKey : @(YES)
                              };
        
        [MKMapItem openMapsWithItems:items launchOptions:dic];
    }];
    [alert addAction:appleAction];
    
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:DDLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancleAction];
    
    [viewController presentViewController:alert animated:YES completion:nil];
}

- (void)checkNotification
{
    if (![UserManager shareManager].isLogin) {
        return;
    }
    
    [CheckNotificationRequest cancelRequest];
    CheckNotificationRequest * request = [[CheckNotificationRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            
            if (data.count == 0) {
                return ;
            }
            
            BOOL xiangling = [DDUserDefaultsGet(@"xiangling") boolValue];
            BOOL zhendong = [DDUserDefaultsGet(@"zhendong") boolValue];
            
            if (xiangling) {
                NSInteger shichangtype = [DDUserDefaultsGet(@"shichangtype") integerValue];
                SystemSoundID soundID;
                //NSBundle来返回音频文件路径
                NSString *soundFile = [[NSBundle mainBundle] pathForResource:@"ten" ofType:@"caf"];
                if (shichangtype == 0) {
                    soundFile = [[NSBundle mainBundle] pathForResource:@"two" ofType:@"caf"];
                }else if (shichangtype == 1) {
                    soundFile = [[NSBundle mainBundle] pathForResource:@"five" ofType:@"caf"];
                }
                //建立SystemSoundID对象，但是这里要传地址(加&符号)。 第一个参数需要一个CFURLRef类型的url参数，要新建一个NSString来做桥接转换(bridge)，而这个NSString的值，就是上面的音频文件路径
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundFile], &soundID);
                //播放提示音 带震动
                AudioServicesPlaySystemSound(soundID);
                AudioServicesRemoveSystemSoundCompletion(soundID);
            }
            
            if (zhendong) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);//让手机震动
            }
            
            NSString * title = [data objectForKey:@"remindTitle"];
            NSString * detail = [data objectForKey:@"remindContent"];
            NSInteger remindId = [[data objectForKey:@"remindId"] integerValue];
            
            UIApplicationState state = [UIApplication sharedApplication].applicationState;
            if (state == UIApplicationStateBackground) {
                [self registerLocaltionNotificationWithTitle:title detail:detail remindId:remindId];
            }else{
                DaoDiAlertView * alert = [[DaoDiAlertView alloc] init];
                alert.handleButtonClicked = ^{
                    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                    if ([lg isKindOfClass:[DDLGSideViewController class]]) {
                        if (lg.leftViewShowing) {
                            [lg hideLeftViewAnimated];
                        }
                        UINavigationController * na = (UINavigationController *)lg.rootViewController;
                        if ([na.topViewController isKindOfClass:[DDNotificationViewController class]]) {
                            [na popViewControllerAnimated:NO];
                            DDNotificationViewController * notification = [[DDNotificationViewController alloc] initWithNotificationID:remindId];
                            [na pushViewController:notification animated:YES];
                        }else{
                            DDNotificationViewController * notification = [[DDNotificationViewController alloc] initWithNotificationID:remindId];
                            [na pushViewController:notification animated:YES];
                        }
                    }
                };
                [alert show];
            }
            
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)registerLocaltionNotificationWithTitle:(NSString *)title detail:(NSString *)detail remindId:(NSInteger)remindId
{
    // 1.创建通知
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    // 2.设置通知的必选参数
    
    // 设置通知显示的内容
    
//    localNotification.alertTitle = title;
    localNotification.alertBody = [NSString stringWithFormat:@"%@\n%@", title, detail];
    localNotification.userInfo = @{@"remindId" : @(remindId)};
    
    // 设置通知的发送时间,单位秒，在多少秒之后推送
    
//    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:2];
    
    //解锁滑动时的事件
    
//    localNotification.alertAction = @"XXOOXX";
    
    //收到通知时App icon的角标
    
//    localNotification.applicationIconBadgeNumber = 0;
    
    //推送是带的声音提醒，设置默认的字段为UILocalNotificationDefaultSoundName
    
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    //设置推送自定义声音格式
    
    //localNotification.soundName = @"文件名.扩展名";
    
    //循环次数
    
//    localNotification.repeatInterval = kCFCalendarUnitDay;
    
    // 3.发送通知(根据项目需要使用)
    
    // 方式一: 根据通知的发送时间(fireDate)发送通知
    
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    // 方式二: 立即发送通知
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

@end
