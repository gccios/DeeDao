//
//  DTieAddGroupTableViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2019/1/14.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDGroupModel.h"
#import "DTieModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DTieAddGroupTableViewCell : UITableViewCell

@property (nonatomic, copy) void (^addButtonHandle)(DDGroupModel * model);
@property (nonatomic, copy) void (^cancleButtonHandle)(DDGroupModel * model);

- (void)configWithModel:(DDGroupModel *)model DtieModel:(DTieModel *)dtie;

@end

NS_ASSUME_NONNULL_END
