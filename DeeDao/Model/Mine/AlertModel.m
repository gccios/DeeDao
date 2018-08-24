//
//  AlertModel.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "AlertModel.h"

@implementation AlertModel

- (instancetype)initWithTitle:(NSString *)title status:(BOOL)status type:(NSInteger)type
{
    if (self = [super init]) {
        self.title = title;
        self.openStatus = status;
        self.type = type;
    }
    return self;
}

@end
