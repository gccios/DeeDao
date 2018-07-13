//
//  SelectPostSeeRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/12.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SelectPostSeeRequest.h"

@implementation SelectPostSeeRequest

- (instancetype)initWithPostID:(NSInteger)postID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = [NSString stringWithFormat:@"post/browsingHistory/selectPostBrowsingHistory/%ld", postID];
    }
    return self;
}

@end
