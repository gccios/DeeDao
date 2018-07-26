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
            if ([WeChatManager shareManager].titleList.count == 1) {
                title = [[WeChatManager shareManager].titleList firstObject];
            }else{
                NSInteger index = arc4random() % [WeChatManager shareManager].titleList.count;
                title = [[WeChatManager shareManager].titleList objectAtIndex:index];
            }
        }else{
            title = @"";
        }
        
        self.detail = title;
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    if (title.length > 18) {
        title = [title substringToIndex:18];
        title = [title stringByAppendingString:@"..."];
    }
    _title = title;
}

- (void)setCodeImage:(UIImage *)codeImage
{
    _codeImage = [self clipMiniProgromCode:codeImage];
}

//- (void)setImage:(UIImage *)image
//{
//    if (image) {
//        _image = [self coreBlurImage:image withBlurNumber:50];
//    }
//}

- (void)changeToDeedao
{
    if (self.image) {
        self.image = [self coreBlurImage:self.image withBlurNumber:50];
    }
}

/**
 使用CoreImage进行高斯模糊
 
 @param image 需要模糊的图片
 @param blur 模糊的范围 可以1~99
 @return 返回已经模糊过的图片
 */
-(UIImage *)coreBlurImage:(UIImage *)image withBlurNumber:(CGFloat)blur
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage= [CIImage imageWithCGImage:image.CGImage];
    //设置filter
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey]; [filter setValue:@(blur) forKey: kCIInputRadiusKey];
    //模糊图片
    CIImage *result=[filter valueForKey:kCIOutputImageKey];
    CGImageRef outImage=[context createCGImage:result fromRect:[inputImage extent]];
    UIImage *blurImage=[UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    return blurImage;
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
