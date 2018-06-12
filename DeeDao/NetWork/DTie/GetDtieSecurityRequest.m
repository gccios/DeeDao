//
//  GetDtieSecurityRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/11.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "GetDtieSecurityRequest.h"

@implementation GetDtieSecurityRequest

- (instancetype)initWithModel:(DTieModel *)model
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        
        NSInteger postID = model.cid;
        if (postID == 0) {
            postID = model.postId;
        }
        
        self.methodName = [NSString stringWithFormat:@"scyGroup/selectMyScyByPostId/%ld/%ld/1", postID, model.landAccountFlg];
        }
    return self;
}

@end
