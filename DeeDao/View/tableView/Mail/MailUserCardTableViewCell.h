//
//  MailUserCardTableViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/7/10.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserMailModel.h"

@interface MailUserCardTableViewCell : UITableViewCell

- (void)configWithModel:(UserMailModel *)model;

@end
