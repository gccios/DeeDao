//
//  DTieNewEditPostCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/7/25.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieEditModel.h"

@interface DTieNewEditPostCell : UITableViewCell

@property (nonatomic, strong) UIButton * addButton;
@property (nonatomic, copy) void (^addButtonHandle)(void);

- (void)configWithModel:(DTieEditModel *)model;

@end
