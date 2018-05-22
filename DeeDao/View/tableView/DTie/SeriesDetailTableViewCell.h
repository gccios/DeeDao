//
//  SeriesDetailTableViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieModel.h"

@interface SeriesDetailTableViewCell : UITableViewCell

@property (nonatomic, copy) void (^seriesShowDTieHandle)(void);

- (void)configWithModel:(DTieModel *)model;

@end
