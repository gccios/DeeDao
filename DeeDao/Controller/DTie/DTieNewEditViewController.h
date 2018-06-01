//
//  DTieNewEditViewController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/31.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"
#import "DTieModel.h"

extern NSString * const DTieDidCreateNewNotification;

@interface DTieNewEditViewController : DDViewController

- (instancetype)initWithDtieModel:(DTieModel *)model;

@end
