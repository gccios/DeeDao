//
//  DTieReadView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/6/1.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieModel.h"

@interface DTieReadView : UIView

@property (nonatomic, weak) UINavigationController * parentDDViewController;

@property (nonatomic, strong) DTieModel * model;

- (instancetype)initWithFrame:(CGRect)frame model:(DTieModel *)model;

@end
