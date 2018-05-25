//
//  SaveUserRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SaveUserRequest.h"

@implementation SaveUserRequest

- (instancetype)initWithName:(NSString *)nickName portraituri:(NSString *)portraituri sex:(NSInteger)sex country:(NSString *)country phone:(NSString *)phone signature:(NSString *)signature
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"user/saveUser";
        
        [self setValue:nickName forParamKey:@"nickname"];
        [self setValue:portraituri forParamKey:@"portraituri"];
        [self setIntegerValue:sex forParamKey:@"sex"];
        [self setValue:country forParamKey:@"country"];
        [self setValue:signature forParamKey:@"signature"];
    }
    return self;
}

@end
