//
//  DDShakeRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2019/1/24.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DDShakeRequest.h"

@implementation DDShakeRequest

- (instancetype)initWithGroupID:(NSInteger)groupID dataSource:(NSInteger)dateSource times:(NSInteger)times
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"/deedaoGroup/manager/selectGroupByRandomNum";
        
        if (groupID > 0) {
            [self setIntegerValue:groupID forParamKey:@"groupId"];
        }
        
        [self setIntegerValue:dateSource forParamKey:@"dataSources"];
        [self setIntegerValue:times forParamKey:@"times"];
    }
    return self;
}

@end
