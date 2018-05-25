//
//  SelectSecurityRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/25.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SelectSecurityRequest.h"

@implementation SelectSecurityRequest

- (instancetype)initWithSelectPostWith:(NSInteger)groupId
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = [NSString stringWithFormat:@"scyGroup/selectMyScyMember/%ld/1", groupId];
    }
    return self;
}

- (instancetype)initWithSelectUserWith:(NSInteger)groupId
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = [NSString stringWithFormat:@"scyGroup/selectMyScyMember/%ld/3", groupId];
    }
    return self;
}

@end
