//
//  CreateDTieRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/15.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "CreateDTieRequest.h"
#import "DDLocationManager.h"
#import "NSArray+json.h"

@implementation CreateDTieRequest

- (instancetype)initWithList:(NSArray *)array title:(NSString *)title
{
    if (self = [super init]) {
        
        self.methodName = @"post/savePost";
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setValue:[DDLocationManager shareManager].result.address forParamKey:@"createAddress"];
        [self setValue:@"113.655554" forParamKey:@"createAddressLng"];
        [self setValue:@"34.756926" forParamKey:@"createAddressLat"];
        [self setValue:title forParamKey:@"postSummary"];
        [self setValue:array forParamKey:@"postDetailList"];
        [self setValue:@[@(166.62),@(39.9)] forParamKey:@"position"];
        [self setIntegerValue:1 forParamKey:@"status"];
//        [self setValue:@"" forParamKey:@"postTagList"];
//        [self setValue:@"" forParamKey:@"allowToSeeList"];
        [self setIntegerValue:0 forParamKey:@"remindFlg"];
        
    }
    return self;
}

@end
