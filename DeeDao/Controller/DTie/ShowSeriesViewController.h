//
//  ShowSeriesViewController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/13.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"
#import "SeriesModel.h"

@interface ShowSeriesViewController : DDViewController

- (instancetype)initWithData:(NSMutableArray *)dataSource series:(SeriesModel *)seriesModel;

@end
