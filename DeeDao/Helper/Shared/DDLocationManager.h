//
//  DDLocationManager.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/15.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import "DTieModel.h"

extern NSString * const DDUserLocationDidUpdateNotification;

@interface DDLocationManager : NSObject

@property (nonatomic, strong) BMKUserLocation * userLocation;
@property (nonatomic, strong) BMKReverseGeoCodeResult * result;

+ (instancetype)shareManager;

- (void)startLocationService;

- (void)stopLocationService;

- (BOOL)contentIsCanSeeWith:(DTieModel *)model detailModle:(DTieEditModel *)detailModel;

- (void)mapNavigationToLongitude:(double)longitude latitude:(double)latitude poiName:(NSString *)name withViewController:(UIViewController *)viewController;

@end
