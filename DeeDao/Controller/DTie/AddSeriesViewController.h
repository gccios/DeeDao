//
//  AddSeriesViewController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"
#import "SeriesDetailModel.h"

@protocol AddSeriesDelegate <NSObject>

- (void)seriesNeedUpdate;

@end

@interface AddSeriesViewController : DDViewController

- (instancetype)initWithSeriesModel:(SeriesDetailModel *)model seriesID:(NSInteger)seriesID;

@property (nonatomic, weak) id<AddSeriesDelegate> delegate;

@end
