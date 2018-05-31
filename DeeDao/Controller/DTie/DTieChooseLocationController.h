//
//  DTieChooseLocationController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/17.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"
#import "DDLocationManager.h"

@protocol ChooseLocationDelegate <NSObject>

- (void)chooseLocationDidChoose:(BMKPoiInfo *)poi;

@end

@interface DTieChooseLocationController : DDViewController

@property (nonatomic, assign) id<ChooseLocationDelegate> delegate;
@property (nonatomic, strong) BMKPoiInfo * startPoi;

@end
