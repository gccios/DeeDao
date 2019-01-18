//
//  DDManagerTableViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2019/1/14.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDManagerTableViewCell : UITableViewCell

- (void)configWithModel:(UserModel *)model;

@end

NS_ASSUME_NONNULL_END
