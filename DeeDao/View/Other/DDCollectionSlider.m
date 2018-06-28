//
//  DDCollectionSlider.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDCollectionSlider.h"

@implementation DDCollectionSlider

- (CGRect)trackRectForBounds:(CGRect)bounds
{
    CGRect rect = [super trackRectForBounds:bounds];
    
    rect.size.height += 3;
    
    return rect;
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    rect.origin.x = rect.origin.x - 12 ;
    
    rect.size.width = rect.size.width +20;
    
    return CGRectInset ([super thumbRectForBounds:bounds trackRect:rect value:value], 10 , 10);
}

@end
