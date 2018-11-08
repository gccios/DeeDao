//
//  FanjuTableViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/28.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieModel.h"

@interface FanjuTableViewCell : UITableViewCell

@property (nonatomic, copy) void (^leftButtonHandle)(void);
@property (nonatomic, copy) void (^rightButtonHandle)(void);

- (void)configWithModel:(DTieModel *)model;

@end
