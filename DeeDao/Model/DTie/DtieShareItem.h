//
//  DtieShareItem.h
//  DeeDao
//
//  Created by 郭春城 on 2018/7/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DtieShareItem : NSObject<UIActivityItemSource>

- (instancetype)initWithImage:(UIImage *)image path:(NSString *)path;

@property (nonatomic, strong) UIImage *img;
@property (nonatomic, strong) NSURL *path;

@end
