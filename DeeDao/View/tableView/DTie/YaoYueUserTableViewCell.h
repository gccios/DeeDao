//
//  YaoYueUserTableViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/7/13.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserYaoYueModel.h"

@interface YaoYueUserTableViewCell : UITableViewCell

@property (nonatomic, copy) void (^yaoyueButtonHandle)(UserYaoYueModel * model);
@property (nonatomic, copy) void (^yiyueButtonHandle)(UserYaoYueModel * model);

- (void)configWithModel:(UserYaoYueModel *)model;

- (void)configSelectStatus:(BOOL)status;

@end
