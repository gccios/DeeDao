//
//  DDLocationManager.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/15.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

extern NSString * const DDUserLocationDidUpdateNotification;

@interface DDLocationManager : NSObject

@property (nonatomic, strong) BMKUserLocation * userLocation;
@property (nonatomic, strong) BMKReverseGeoCodeResult * result;

+ (instancetype)shareManager;

- (void)startLocationService;

- (void)stopLocationService;

@end
