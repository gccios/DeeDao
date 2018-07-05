//
//  CreateLocationRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/5.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "CreateLocationRequest.h"
#import "DDTool.h"
#import "UserManager.h"

@implementation CreateLocationRequest

- (instancetype)initWithAddress:(NSString *)address name:(NSString *)name lat:(double)lat lng:(double)lng remark:(NSString *)remark
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"deedaoPoint/addDeedaoPoint";
        
        [self setValue:address forParamKey:@"createAddress"];
        [self setValue:name forParamKey:@"createBuilding"];
        [self setDoubleValue:lng forParamKey:@"createAddressLng"];
        [self setDoubleValue:lat forParamKey:@"createAddressLat"];
        NSString * date = [DDTool getCurrentTimeWithFormat:@"yyyy-MM-dd HH:mm:ss"];
        [self setValue:date forParamKey:@"createTime"];
        [self setIntegerValue:[UserManager shareManager].user.cid forParamKey:@"authorId"];
        [self setIntegerValue:0 forParamKey:@"deleteFlg"];
        [self setValue:remark forParamKey:@"remark"];
    }
    return self;
}

@end
