
//
//  GetUserCreateLocationRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/5.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "GetUserCreateLocationRequest.h"

@implementation GetUserCreateLocationRequest

- (instancetype)initWithKeyWord:(NSString *)keyWord lat:(double)lat lng:(double)lng
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"deedaoPoint/selectDeedaoPoint";
        
        if (isEmptyString(keyWord)) {
            keyWord = @"";
        }
        [self setValue:keyWord forParamKey:@"keyword"];
        [self setDoubleValue:lat forParamKey:@"lat"];
        [self setDoubleValue:lng forParamKey:@"lng"];
    }
    return self;
}

@end
