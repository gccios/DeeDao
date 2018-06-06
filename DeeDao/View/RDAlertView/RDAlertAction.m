//
//  RDAlertAction.m
//  Test - 2.1
//
//  Created by 郭春城 on 17/3/7.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDAlertAction.h"

@implementation RDAlertAction

- (instancetype)initWithTitle:(NSString *)title handler:(void (^)())handler bold:(BOOL)bold
{
    if (self = [super init]) {
        
        [self setTitle:title forState:UIControlStateNormal];
        self.block = handler;
        if (bold) {
            [self setBackgroundColor:UIColorFromRGB(0xffffff)];
            self.titleLabel.font = kPingFangLight(16);
            [self setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
        }else{
            self.titleLabel.font = kPingFangRegular(16);
            [self setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
        }
        
    }
    return self;
}

- (instancetype)initVersionWithTitle:(NSString *)title handler:(void (^)())handler bold:(BOOL)bold
{
    if (self = [super init]) {
        
        [self setTitle:title forState:UIControlStateNormal];
        self.block = handler;
        [self setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
        if (bold) {
            self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        }else{
            self.titleLabel.font = [UIFont systemFontOfSize:17];
        }
    }
    return self;
}

@end
