//
//  DDCollectionTableViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/16.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieEditModel.h"

@interface DDCollectionTableViewCell : UITableViewCell

- (void)configWithModel:(DTieEditModel *)model;

- (void)configFirstWithModel:(DTieEditModel *)model firstTime:(NSString *)firstTime location:(NSString *)location updateTime:(NSString *)updateTime;

@end
