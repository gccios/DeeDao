//
//  CreateDTieRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/15.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "CreateDTieRequest.h"
#import "DDLocationManager.h"
#import "DDTool.h"

@implementation CreateDTieRequest

- (instancetype)initWithList:(NSArray *)array title:(NSString *)title address:(NSString *)address addressLng:(double)addressLng addressLat:(double)addressLat status:(NSInteger)status remindFlg:(NSInteger)remindFlg firstPic:(NSString *)firstPic postID:(NSInteger)postId landAccountFlg:(NSInteger)landAccountFlg allowToSeeList:(NSArray *)allowToSeeList sceneTime:(NSInteger)sceneTime;
{
    if (self = [super init]) {
        
        self.methodName = @"post/savePost";
        self.httpMethod = BGNetworkRequestHTTPPost;
        [self setValue:address forParamKey:@"createAddress"];
        [self setValue:address forParamKey:@"createBuilding"];
        [self setDoubleValue:addressLng forParamKey:@"createAddressLng"];
        [self setDoubleValue:addressLat forParamKey:@"createAddressLat"];
        [self setValue:title forParamKey:@"postSummary"];
        [self setValue:array forParamKey:@"postDetailList"];
        [self setValue:@[@(addressLng),@(addressLat)] forParamKey:@"position"];
        [self setIntegerValue:status forParamKey:@"status"];
        [self setIntegerValue:remindFlg forParamKey:@"remindFlg"];
        [self setValue:firstPic forParamKey:@"postFirstPicture"];
        [self setIntegerValue:5 forParamKey:@"postTypeId"];
        [self setIntegerValue:landAccountFlg forParamKey:@"landAccountFlg"];
        
        NSString * sceneTimeStr = [DDTool getTimeWithFormat:@"yyyy-MM-dd HH:mm" time:sceneTime];
        [self setValue:sceneTimeStr forParamKey:@"sceneTime"];
        
        if (allowToSeeList) {
            [self setValue:allowToSeeList forParamKey:@"allowToSeeList"];
        }
        
        if (postId) {
            [self setIntegerValue:postId forParamKey:@"postId"];
        }
        
    }
    return self;
}

@end
