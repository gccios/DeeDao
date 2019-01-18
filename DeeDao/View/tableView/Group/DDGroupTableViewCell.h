//
//  DDGroupTableViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2019/1/7.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDGroupModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDGroupTableViewCell : UITableViewCell

@property (nonatomic, copy) void (^mapButtonHandle)(DDGroupModel * model);
@property (nonatomic, copy) void (^listButtonHandle)(DDGroupModel * model);


- (void)configWithMyGroupWithModel:(DDGroupModel *)model;

- (void)configWithOtherPublicWithModel:(DDGroupModel *)model;

@end

NS_ASSUME_NONNULL_END
