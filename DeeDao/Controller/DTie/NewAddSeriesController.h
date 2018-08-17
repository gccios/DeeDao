//
//  NewAddSeriesController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/7.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"
#import "SeriesDetailModel.h"
#import "SeriesModel.h"

@interface NewAddSeriesController : DDViewController

- (instancetype)initWithDataSource:(NSArray *)dataSource series:(SeriesModel *)seriesModel;

@end
