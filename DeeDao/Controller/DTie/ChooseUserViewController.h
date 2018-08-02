//
//  ChooseUserViewController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/1.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"

@protocol ChooseUserDelegate <NSObject>

- (void)userDidCompleteSelectWith:(NSArray *)selectArray;

@end

@interface ChooseUserViewController : DDViewController

@property (nonatomic, weak) id<ChooseUserDelegate> delegate;

- (instancetype)initWithUsers:(NSMutableArray *)users;

@end
