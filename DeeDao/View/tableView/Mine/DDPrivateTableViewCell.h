//
//  DDPrivateTableViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/14.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecurityGroupModel.h"

@interface DDPrivateTableViewCell : UITableViewCell

- (void)configWithModel:(SecurityGroupModel *)model;

@end