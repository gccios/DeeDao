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

- (instancetype)initWithList:(NSArray *)array title:(NSString *)title address:(NSString *)address building:(NSString *)building addressLng:(double)addressLng addressLat:(double)addressLat status:(NSInteger)status remindFlg:(NSInteger)remindFlg firstPic:(NSString *)firstPic postID:(NSInteger)postId landAccountFlg:(NSInteger)landAccountFlg allowToSeeList:(NSArray *)allowToSeeList sceneTime:(NSInteger)sceneTime
{
    if (self = [super init]) {
        
        self.methodName = @"post/savePost";
        self.httpMethod = BGNetworkRequestHTTPPost;
        
        if (isEmptyString([DDLocationManager shareManager].result.address)) {
            [self setValue:@"" forParamKey:@"createAddress"];
            [self setValue:@"" forParamKey:@"createBuilding"];
        }else{
            [self setValue:[DDLocationManager shareManager].result.address forParamKey:@"createAddress"];
            [self setValue:[DDLocationManager shareManager].result.address forParamKey:@"createBuilding"];
        }
        
        [self setDoubleValue:[DDLocationManager shareManager].result.location.longitude forParamKey:@"createAddressLng"];
        [self setDoubleValue:[DDLocationManager shareManager].result.location.latitude forParamKey:@"createAddressLat"];
        
        if (!isEmptyString(address)) {
            [self setValue:address forParamKey:@"sceneAddress"];
            [self setValue:building forParamKey:@"sceneBuilding"];
        }
        [self setDoubleValue:addressLng forParamKey:@"sceneAddressLng"];
        [self setDoubleValue:addressLat forParamKey:@"sceneAddressLat"];
        
        if (!isEmptyString(title)) {
            [self setValue:title forParamKey:@"postSummary"];
        }
        if (array) {
            [self setValue:array forParamKey:@"postDetailList"];
        }
        if (!isEmptyString(firstPic)) {
            [self setValue:firstPic forParamKey:@"postFirstPicture"];
        }
        
        [self setValue:@[@(addressLng),@(addressLat)] forParamKey:@"position"];
        [self setIntegerValue:status forParamKey:@"status"];
        [self setIntegerValue:remindFlg forParamKey:@"remindFlg"];
        [self setIntegerValue:5 forParamKey:@"postTypeId"];
        [self setIntegerValue:landAccountFlg forParamKey:@"landAccountFlg"];
        [self setIntegerValue:1 forParamKey:@"remindFlg"];
        
        NSString * sceneTimeStr = [DDTool getTimeWithFormat:@"yyyy-MM-dd HH:mm" time:sceneTime];
        if (!isEmptyString(sceneTimeStr)) {
            [self setValue:sceneTimeStr forParamKey:@"sceneTime"];
        }
        
        if (allowToSeeList) {
            [self setValue:allowToSeeList forParamKey:@"allowToSeeList"];
        }else{
            [self setValue:[NSArray new] forParamKey:@"allowToSeeList"];
        }
        
        if (postId) {
            [self setIntegerValue:postId forParamKey:@"postId"];
        }
        
    }
    return self;
}

- (void)configRemark:(NSString *)remark
{
    [self setValue:remark forParamKey:@"remark"];
}

- (instancetype)initChangeFirstPicWithPostID:(NSInteger)postID image:(NSString *)image
{
    if (self = [super init]) {
        self.methodName = @"post/changeFristPicture";
        self.httpMethod = BGNetworkRequestHTTPPost;
        
        [self setIntegerValue:postID forParamKey:@"postId"];
        [self setValue:image forParamKey:@"firstPicture"];
    }
    return self;
}

- (instancetype)initAddWithPostID:(NSInteger)postID blocks:(NSArray *)blocks
{
    if (self = [super init]) {
        self.methodName = @"post/uploadPicAuthor";
        self.httpMethod = BGNetworkRequestHTTPPost;
        
        [self setIntegerValue:postID forParamKey:@"postId"];
        [self setValue:blocks forParamKey:@"postDetailList"];
    }
    return self;
}

- (instancetype)initAddWYYWithPostID:(NSInteger)postID blocks:(NSArray *)blocks
{
    if (self = [super init]) {
        self.methodName = @"post/uploadPic";
        self.httpMethod = BGNetworkRequestHTTPPost;
        
        [self setIntegerValue:postID forParamKey:@"postId"];
        [self setValue:blocks forParamKey:@"postDetailList"];
    }
    return self;
}

- (instancetype)initRepelaceWithPostID:(NSInteger)postID details:(NSArray *)details
{
    if (self = [super init]) {
        
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/replaceDetailList";
        
        [self setIntegerValue:postID forParamKey:@"postId"];
        [self setValue:details forParamKey:@"postDetailList"];
        
    }
    return self;
}

@end
