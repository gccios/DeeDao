//
//  DTieNewDetailViewController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/6/1.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"
#import "DTieModel.h"

@interface DTieNewDetailViewController : DDViewController

- (instancetype)initWithDTie:(DTieModel *)model;

- (instancetype)initPreReadWithDTie:(DTieModel *)model;

- (void)showShareWithCreatePost;

@end
