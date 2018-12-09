//
//  DTieDetailPostTableViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/7/26.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieModel.h"

@interface DTieDetailPostTableViewCell : UITableViewCell

@property (nonatomic, strong) UIButton * addButton;

@property (nonatomic, copy) void (^addButtonHandle)(void);
@property (nonatomic, copy) void (^upButtonHandle)(void);
@property (nonatomic, copy) void (^downButtonHandle)(void);
@property (nonatomic, copy) void (^deleteButtonHandle)(void);
@property (nonatomic, copy) void (^editButtonHandle)(void);

- (void)configWithModel:(DTieEditModel *)model Dtie:(DTieModel *)dtieModel;

@end
