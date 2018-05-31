//
//  DTieNewEditTextCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/31.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieEditModel.h"

@interface DTieNewEditTextCell : UITableViewCell

@property (nonatomic, strong) DTieEditModel * model;
@property (nonatomic, strong) UIButton * addButton;
@property (nonatomic, copy) void (^addButtonHandle)(void);

- (void)configWithModel:(DTieEditModel *)model;

@end
