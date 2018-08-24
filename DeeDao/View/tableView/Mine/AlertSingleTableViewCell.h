//
//  AlertSingleTableViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertModel.h"

@interface AlertSingleTableViewCell : UITableViewCell

- (void)configTitle:(NSString *)title;

- (void)configChooseStatus:(BOOL)chooseStaus;

@end
