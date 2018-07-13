//
//  AddPostSeeRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/12.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "AddPostSeeRequest.h"
#import "DDLocationManager.h"
#import "UserManager.h"
#import "DDTool.h"

@implementation AddPostSeeRequest

- (instancetype)initWithPostID:(NSInteger)postID
{
    if (self = [super init]) {
        
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/browsingHistory/addPostBrowsingHistory";
        
        [self setDoubleValue:[DDLocationManager shareManager].result.location.longitude forParamKey:@"createAddressLng"];
        [self setDoubleValue:[DDLocationManager shareManager].result.location.latitude forParamKey:@"createAddressLat"];
        
        if (isEmptyString([DDLocationManager shareManager].result.address)) {
            [self setValue:@"" forParamKey:@"createAddress"];
            [self setValue:@"" forParamKey:@"createBuilding"];
        }else{
            [self setValue:[DDLocationManager shareManager].result.address forParamKey:@"createAddress"];
            [self setValue:[DDLocationManager shareManager].result.address forParamKey:@"createBuilding"];
        }
        
        [self setIntegerValue:[DDTool getTimeCurrentWithDouble] forParamKey:@"createTime"];
        [self setIntegerValue:postID forParamKey:@"postId"];
        [self setIntegerValue:[UserManager shareManager].user.cid forParamKey:@"browserUserId"];
        
        if (isEmptyString([DDLocationManager shareManager].result.addressDetail.city)) {
            [self setValue:@"" forParamKey:@"createCity"];
        }else{
            [self setValue:[DDLocationManager shareManager].result.addressDetail.city forParamKey:@"createCity"];
        }
        
    }
    return self;
}

@end
