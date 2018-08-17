//
//  NotificationCollectionViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/13.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationHistoryModel.h"

@interface NotificationCollectionViewCell : UICollectionViewCell

- (void)configWithModel:(NotificationHistoryModel *)model;

@end
