//
//  GetTelCodeRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/5.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "GetTelCodeRequest.h"

@implementation GetTelCodeRequest

- (instancetype)initWithTelNumber:(NSString *)telNumber
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = [NSString stringWithFormat:@"sendCode/sendToLogin/%@", telNumber];
    }
    return self;
}

@end
