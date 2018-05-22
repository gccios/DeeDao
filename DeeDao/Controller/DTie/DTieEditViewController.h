//
//  DTieEditViewController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/11.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"
#import "DTieModel.h"

extern NSString * const DTieDidCreateNotification;

@interface DTieEditViewController : DDViewController

- (instancetype)initWithTitle:(NSString *)title address:(NSString *)address;

- (instancetype)initWithDtieModel:(DTieModel *)model;

@end
