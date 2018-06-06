//
//  DDShareManager.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/28.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDShareManager : NSObject

+ (instancetype)shareManager;

@property (nonatomic, weak) UIButton * tempNumberLabel;

@property (nonatomic, assign) NSInteger editShareCount;

- (void)showShareList;

- (void)showHandleViewWithImage:(UIImage *)image;

- (void)updateNumber;

@end
