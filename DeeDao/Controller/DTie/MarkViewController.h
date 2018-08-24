//
//  MarkViewController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"
#import "DDLocationManager.h"

@interface MarkViewController : DDViewController

- (instancetype)initWithBMKPoiInfo:(BMKPoiInfo *)poiInfo friendArray:(NSArray *)friendArray;

@end
