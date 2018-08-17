//
//  ChooseTypeButton.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/15.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "ChooseTypeButton.h"

@implementation ChooseTypeButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGFloat width = self.frame.size.width;
    CGFloat radius = width / 2.f;
    
    CGFloat distanceX;
    CGFloat distanceY;
    
    if (point.x < radius) {
        distanceX = fabs(radius - point.x);
    }else{
        distanceX = point.x - radius;
    }
    
    if (point.y < radius) {
        distanceY = fabs(radius - point.y);
    }else{
        distanceY = point.y - radius;
    }
    
    CGFloat distance = sqrt(distanceX * distanceX + distanceY * distanceY);
    if (distance <= radius) {
        return YES;
    }
    
    return NO;
}

@end
