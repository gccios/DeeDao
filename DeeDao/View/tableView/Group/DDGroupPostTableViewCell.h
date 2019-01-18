//
//  DDGroupPostTableViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2019/1/10.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDGroupPostTableViewCell : UITableViewCell

@property (nonatomic, copy) void (^toApplyButtonHandle)(DTieModel * model);
@property (nonatomic, copy) void (^applyButtonHandle)(DTieModel * model);
@property (nonatomic, copy) void (^deleteButtonHandle)(DTieModel * model);

- (void)configPostWithModel:(DTieModel *)model;

- (void)configApplyWithModel:(DTieModel *)model;

@end

NS_ASSUME_NONNULL_END
