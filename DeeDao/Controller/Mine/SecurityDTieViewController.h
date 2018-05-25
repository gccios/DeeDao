//
//  SecurityDTieViewController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/25.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"

@class DTieModel;
@protocol SecurityDTieViewDelegate <NSObject>

- (void)securityDidChooseWith:(DTieModel *)model;

@end

@interface SecurityDTieViewController : DDViewController

@property (nonatomic, weak) id<SecurityDTieViewDelegate> delegate;

- (instancetype)initWithChooseSource:(NSMutableArray *)chooseSource DTieSource:(NSMutableArray *)DTieSource;

@end
