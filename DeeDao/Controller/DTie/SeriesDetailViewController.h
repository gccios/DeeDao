//
//  SeriesDetailViewController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/23.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"
#import "SeriesDetailModel.h"

@interface SeriesDetailViewController : DDViewController

- (instancetype)initWithTitle:(NSString *)title source:(NSArray *)source;

- (instancetype)initWithSeriesModel:(SeriesDetailModel *)model;

@end
