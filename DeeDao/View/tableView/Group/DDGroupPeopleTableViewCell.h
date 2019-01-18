//
//  DDGroupPeopleTableViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2019/1/10.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDGroupPeopleTableViewCell : UITableViewCell

@property (nonatomic, copy) void (^toApplyButtonHandle)(UserModel * model);
@property (nonatomic, copy) void (^applyButtonHandle)(UserModel * model);
@property (nonatomic, copy) void (^deleteButtonHandle)(UserModel * model);
@property (nonatomic, copy) void (^giveButtonHandle)(UserModel * model);

- (void)configPeopleWithModel:(UserModel *)model;

- (void)configApplyWithModel:(UserModel *)model;

- (void)configGiveWithModel:(UserModel *)model;

@end

NS_ASSUME_NONNULL_END
