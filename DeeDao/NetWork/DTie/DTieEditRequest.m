//
//  DTieEditRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/11/15.
//  Copyright © 2018 郭春城. All rights reserved.
//

#import "DTieEditRequest.h"

@implementation DTieEditRequest

- (instancetype)initWithTitle:(NSString *)title postID:(NSInteger)postID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/editSummary";
        
        [self setIntegerValue:postID forParamKey:@"postId"];
        [self setValue:title forParamKey:@"summary"];
    }
    return self;
}

- (instancetype)initWithTime:(NSInteger)time postID:(NSInteger)postID
{
    if (self = [super init]) {
        
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/editScenetime";
        
        [self setIntegerValue:postID forParamKey:@"postId"];
        [self setIntegerValue:time forParamKey:@"scenetime"];
        
    }
    return self;
}

- (instancetype)initWithAddress:(NSString *)address building:(NSString *)building lat:(double)lat lng:(double)lng postID:(NSInteger)postID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/editSceneaddress";
        
        [self setIntegerValue:postID forParamKey:@"postId"];
        [self setValue:address forParamKey:@"sceneAddress"];
        [self setValue:building forParamKey:@"sceneBuilding"];
        [self setDoubleValue:lat forParamKey:@"sceneLat"];
        [self setDoubleValue:lng forParamKey:@"sceneLng"];
    }
    return self;
}

- (instancetype)initWithStaus:(NSInteger)status postID:(NSInteger)postID
{
    if (self = [super init]) {
        
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/editStatus";
        
        [self setIntegerValue:postID forParamKey:@"postId"];
        [self setIntegerValue:status forParamKey:@"status"];
        
    }
    return self;
}

- (instancetype)initWithAccountFlg:(NSInteger)accountFlg groupList:(NSArray *)groupList postID:(NSInteger)postID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/editPostSecurity";
        
        [self setIntegerValue:postID forParamKey:@"postId"];
        [self setIntegerValue:accountFlg forParamKey:@"landAccountflg"];
        if (groupList) {
            [self setValue:groupList forParamKey:@"securityGroupIdList"];
        }
    }
    return self;
}

@end
