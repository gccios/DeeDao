//
//  SeriesTableHeaderView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeriesTableHeaderView : UITableViewHeaderFooterView

@property (nonatomic, copy) void (^addSeriesHandle)(void);

- (void)configWithSetTop:(BOOL)isTop;

@end
