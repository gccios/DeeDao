//
//  DDPrivateViewController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/14.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"
#import "SecurityGroupModel.h"

@protocol DDPrivateViewSelectDelegate <NSObject>

- (void)securityDidSelectWith:(SecurityGroupModel *)model;

@end

@interface DDPrivateViewController : DDViewController

@property (nonatomic, weak) id<DDPrivateViewSelectDelegate> delegate;

@end
