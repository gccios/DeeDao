//
//  ShareImageItem.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/31.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareImageItem : NSObject<UIActivityItemSource>

-(instancetype)initWithData:(UIImage*)img andFile:(NSURL*)file;

@property (nonatomic, strong) UIImage *img;
@property (nonatomic, strong) NSURL *path;

@end
