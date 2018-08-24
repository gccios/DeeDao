//
//  DDCollectionListViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/16.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieModel.h"

@interface DDCollectionListViewCell : UICollectionViewCell

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, copy) void (^tableViewClickHandle)(NSIndexPath * cellIndex);

- (void)configWithModel:(DTieModel *)model tag:(NSInteger)tag;

@end
