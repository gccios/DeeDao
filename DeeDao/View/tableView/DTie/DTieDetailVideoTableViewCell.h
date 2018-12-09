//
//  DTieDetailVideoTableViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/17.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieModel.h"

@interface DTieDetailVideoTableViewCell : UITableViewCell

@property (nonatomic, strong) UIButton * addButton;

@property (nonatomic, copy) void (^addButtonHandle)(void);
@property (nonatomic, copy) void (^upButtonHandle)(void);
@property (nonatomic, copy) void (^downButtonHandle)(void);
@property (nonatomic, copy) void (^deleteButtonHandle)(void);
@property (nonatomic, copy) void (^editButtonHandle)(void);
@property (nonatomic, copy) void (^shouldUpdateHandle)(void);

//- (void)configWithCanSee:(BOOL)cansee;
//
//- (void)configWithModel:(DTieEditModel *)model;

- (void)configWithModel:(DTieEditModel *)model Dtie:(DTieModel *)dtieModel;

//- (void)yulanWithModel:(DTieEditModel *)model;

@end
