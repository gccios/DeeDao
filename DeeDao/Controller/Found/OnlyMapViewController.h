//
//  OnlyMapViewController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"

@class OnlyMapViewController;
@protocol OnlyMapViewControllerDelegate <NSObject>

- (void)viewControllerDidReceiveTap:(OnlyMapViewController *)viewController;

@end

@interface OnlyMapViewController : DDViewController

@property (nonatomic, assign) NSInteger year;

@property (nonatomic, weak) id<OnlyMapViewControllerDelegate> delegate;

- (void)addOnlyMapWith:(UIView *)view;

@end
