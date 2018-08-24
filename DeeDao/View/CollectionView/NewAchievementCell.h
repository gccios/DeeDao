//
//  NewAchievementCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AchievementModel.h"

@interface NewAchievementCell : UICollectionViewCell

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, copy) void (^tableViewClickHandle)(NSIndexPath * cellIndex);

- (void)configWithModel:(AchievementModel *)model tag:(NSInteger)tag;

@end
