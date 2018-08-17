//
//  SeriesSelectTableViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeriesModel.h"

@interface SeriesSelectTableViewCell : UITableViewCell

- (void)configWithSeriesModel:(SeriesModel *)model;

- (void)configSelectStatus:(BOOL)status;

@end
