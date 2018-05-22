//
//  SeriesChoosDTieController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"
#import "DTieModel.h"

@protocol SeriesChoosDTieDelegate <NSObject>

- (void)seriesWillInsertWith:(DTieModel *)model;

@end

@interface SeriesChoosDTieController : DDViewController

@property (nonatomic, weak) id<SeriesChoosDTieDelegate> delegate;

@end
