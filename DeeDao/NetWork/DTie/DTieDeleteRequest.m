//
//  DTieDeleteRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/3.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieDeleteRequest.h"

@implementation DTieDeleteRequest

- (instancetype)initWithPostId:(NSInteger)postID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = [NSString stringWithFormat:@"post/deletePost/%ld", postID];
    }
    return self;
}

@end
