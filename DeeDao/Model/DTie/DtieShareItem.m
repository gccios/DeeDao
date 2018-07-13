//
//  DtieShareItem.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DtieShareItem.h"

@implementation DtieShareItem

- (instancetype)initWithImage:(UIImage *)image path:(NSString *)path
{
    if (self = [super init]) {
        self.img = image;
        self.path = [NSURL fileURLWithPath:path];
    }
    return self;
}

#pragma mark - UIActivityItemSource
-(id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return _img;
}

-(id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    return _path;
}

//-(NSString*)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
//{
//    // 这里对我这分享图好像没啥用....   是的 没啥用....
//    return @"";
//}

@end
