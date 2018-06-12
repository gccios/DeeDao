//
//  ShareImageModel.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/8.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "ShareImageModel.h"
#import "WeChatManager.h"

@implementation ShareImageModel

- (instancetype)init
{
    if (self = [super init]) {
        
        NSString * title = @"长按看更多 收藏免错过";
        if ([WeChatManager shareManager].titleList.count > 0) {
            NSInteger index = arc4random() % [WeChatManager shareManager].titleList.count;
            title = [[WeChatManager shareManager].titleList objectAtIndex:index];
        }
        
        self.detail = title;
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    if (title.length > 12) {
        title = [title substringToIndex:12];
        title = [title stringByAppendingString:@"..."];
    }
    _title = title;
}

- (void)setCodeImage:(UIImage *)codeImage
{
    _codeImage = [self clipMiniProgromCode:codeImage];
}

- (UIImage *)clipMiniProgromCode:(UIImage *)codeImage
{
    //1.创建图片上下文
    
    UIGraphicsBeginImageContextWithOptions(codeImage.size, NO, [UIScreen mainScreen].scale);
    
    // 2.描述圆形路径
    
    UIBezierPath*path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0,0,codeImage.size.width,codeImage.size.height)];
    
    // 3.设置裁剪区域
    
    [path addClip];
    
    // 4.画图
    
    [codeImage drawAtPoint:CGPointZero];
    UIImage*newImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
