//
//  SelectWYYBlockRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SelectWYYBlockRequest.h"

@implementation SelectWYYBlockRequest

- (instancetype)initWithPostID:(NSInteger)postID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = [NSString stringWithFormat:@"post/selectWYYBlock/%ld", postID];
    }
    return self;
}

@end
