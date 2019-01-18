//
//  DDGroupSearchRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2019/1/15.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DDGroupSearchRequest.h"

@implementation DDGroupSearchRequest

- (instancetype)initSearchGroupWithKeyWord:(NSString *)keyWord
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = [[NSString stringWithFormat:@"deedaoGroup/searchMyDeedaoGroup/%@", keyWord] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return self;
}

- (instancetype)initSearchPublicWithKeyWord:(NSString *)keyWord
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = [[NSString stringWithFormat:@"deedaoGroup/searchNotMyPublicDeedaoGroup/%@", keyWord] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return self;
}

@end
