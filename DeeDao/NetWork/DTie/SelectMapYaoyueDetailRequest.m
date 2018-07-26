//
//  SelectMapYaoyueDetailRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/26.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SelectMapYaoyueDetailRequest.h"

@implementation SelectMapYaoyueDetailRequest

- (instancetype)initWithAddress:(NSString *)address
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/collection/selectWYYFriendsMapDetail";
        
        [self setValue:address forParamKey:@"sceneAddress"];
    }
    return self;
}

@end
