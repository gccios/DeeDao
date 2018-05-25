//
//  DDLocationManager.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/15.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDLocationManager.h"
#import <BaiduMapAPI_Utils/BMKGeometry.h>

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
    [self stopLocationService];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DDUserLocationDidUpdateNotification object:nil];
}

#pragma mark ----反向地理编码
- (void)reverseGeoCodeWith:(CLLocationCoordinate2D)coordinate
{
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeocodeSearchOption.reverseGeoPoint = coordinate;
    [self.geocodesearch reverseGeoCode:reverseGeocodeSearchOption];;
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    self.result = result;
}

- (BOOL)contentIsCanSeeWith:(DTieModel *)model detailModle:(DTieEditModel *)detailModel
{
    if (detailModel.pFlag == 0) {
        return YES;
    }
    
    BMKMapPoint userPoint = BMKMapPointForCoordinate(self.userLocation.location.coordinate);
    BMKMapPoint point = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(model.sceneAddressLat, model.sceneAddressLng));
    CLLocationDistance distance = BMKMetersBetweenMapPoints(userPoint, point);
    
    if (distance > 500) {
        return NO;
    }
    
    return YES;
}

@end
