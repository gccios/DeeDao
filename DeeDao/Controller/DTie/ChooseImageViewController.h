//
//  ChooseImageViewController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"

@interface ChooseImageViewController : DDViewController

@property (nonatomic, copy) void (^chooseImageHandle)(UIImage * image);

- (instancetype)initWithImage:(UIImage *)image;

@end
