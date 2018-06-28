//
//  DDShareManager.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/28.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareImageModel.h"

@interface DDShareManager : NSObject

+ (instancetype)shareManager;

@property (nonatomic, weak) UIButton * tempNumberLabel;

- (void)showShareList;

- (void)showHandleViewWithImage:(ShareImageModel *)image;

- (void)updateNumber;

@end
