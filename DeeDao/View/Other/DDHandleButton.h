//
//  DDHandleButton.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/18.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDHandleButton : UIButton

@property (nonatomic, strong) UIImageView * handleImageView;
@property (nonatomic, strong) UILabel * handleLabel;

- (void)configImage:(UIImage *)image;

- (void)configTitle:(NSString *)title;

@end
