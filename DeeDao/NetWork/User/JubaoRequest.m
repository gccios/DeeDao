//
//  JubaoRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/7.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "JubaoRequest.h"

@implementation JubaoRequest

- (instancetype)initWithPostViewId:(NSInteger)postViewId postComplaintContent:(NSString *)postComplaintContent complaintOwner:(NSInteger)complaintOwner
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/reportPost";
        
        [self setIntegerValue:postViewId forParamKey:@"postId"];
    }
    return self;
}

@end
