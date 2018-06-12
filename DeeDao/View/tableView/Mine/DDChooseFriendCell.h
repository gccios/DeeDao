//
//  DDChooseFriendCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/6/7.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

@interface DDChooseFriendCell : UITableViewCell

- (void)configWithModel:(UserModel *)model;

- (void)configIsChoose:(BOOL)isChoose;

@end
