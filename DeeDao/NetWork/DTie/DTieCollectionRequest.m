//
//  DTieCollectionRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieCollectionRequest.h"

@implementation DTieCollectionRequest

- (instancetype)initWithPostID:(NSInteger)postId type:(NSInteger)type subType:(NSInteger)subType remark:(NSString *)remark
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/collection/savePostCollection";
        [self setIntegerValue:postId forParamKey:@"postId"];
        [self setIntegerValue:type forParamKey:@"type"];
        if (subType != 0) {
            [self setIntegerValue:subType forParamKey:@"subType"];
        }
        [self setValue:remark forParamKey:@"remark"];
    }
    return self;
}

@end
