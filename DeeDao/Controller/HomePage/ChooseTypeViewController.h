//
//  ChooseTypeViewController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/15.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"

@protocol ChooseTypeViewControllerDelegate <NSObject>

- (void)typeDidChooseComplete:(NSInteger)chooseTag;

@end

@interface ChooseTypeViewController : DDViewController

- (instancetype)initWithSourceType:(NSInteger)sourceType;

@property (nonatomic, weak) id<ChooseTypeViewControllerDelegate> delegate;

@end
