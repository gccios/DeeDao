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

NSString * const DDUserLocationDidUpdateNotification = @"DDUserLocationDidUpdateNotification";

@interface DDLocationManager () <BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>

@property (nonatomic, strong) BMKLocationService * locationService;
@property (nonatomic, strong) BMKGeoCodeSearch *geocodesearch;

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
        self.distance = 500;
    }
    return self;
}

- (void)setUpLocationManager
{
    self.locationService = [[BMKLocationService alloc] init];
    self.locationService.delegate = self;
    self.locationService.distanceFilter = 10.f;
    self.locationService.desiredAccuracy = kCLLocationAccuracyBest;
    
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
    
    UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancleAction];
    
    [viewController presentViewController:alert animated:YES completion:nil];
}

@end
