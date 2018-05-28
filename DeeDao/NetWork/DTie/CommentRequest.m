//
//  CommentRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/23.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "CommentRequest.h"

@implementation CommentRequest

- (instancetype)initWithPostID:(NSInteger)postId
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = [NSString stringWithFormat:@"post/comment/selectCommentByPostViewId/%ld", postId];
    }
    return self;
}


@end
