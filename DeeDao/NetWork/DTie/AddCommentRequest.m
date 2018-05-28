//
//  AddCommentRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/23.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "AddCommentRequest.h"
#import "UserManager.h"

@implementation AddCommentRequest

- (instancetype)initWithPostID:(NSInteger)postId commentContent:(NSString *)commentContent
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/comment/addPostComment";
        
        [self setIntegerValue:postId forParamKey:@"postViewId"];
        [self setValue:commentContent forParamKey:@"commentContent"];
        [self setIntegerValue:[UserManager shareManager].user.cid forParamKey:@"commentatorId"];
    }
    return self;
}

@end
