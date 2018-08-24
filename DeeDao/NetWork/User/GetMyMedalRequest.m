//
//  GetMyMedalRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "GetMyMedalRequest.h"

@implementation GetMyMedalRequest

- (instancetype)init
{
    if (self = [super init]) {
        
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = @"medal/myMedal";
        
    }
    return self;
}

@end
