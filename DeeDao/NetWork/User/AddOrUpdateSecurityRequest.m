//
//  AddOrUpdateSecurityRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/25.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "AddOrUpdateSecurityRequest.h"
#import "DTieModel.h"
#import "UserModel.h"

@implementation AddOrUpdateSecurityRequest

- (instancetype)initWithCreatePerson:(NSInteger)createPerson deleteFlg:(NSInteger)deleteFlg groupId:(NSInteger)groupId groupName:(NSString *)groupName groupPropName:(NSString *)groupPropName posts:(NSArray *)posts friends:(NSArray *)friends
{
    if (self = [super init]) {
        
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"scyGroup/addOrUpdateScy";
        
        NSMutableDictionary * securitygroup = [[NSMutableDictionary alloc] init];
        [securitygroup setObject:@(createPerson) forKey:@"createPerson"];
        [securitygroup setObject:@(deleteFlg) forKey:@"deleteFlg"];
        if (groupId) {
            [securitygroup setObject:@(groupId) forKey:@"id"];
        }
        [securitygroup setObject:groupName forKey:@"securitygroupName"];
        if (isEmptyString(groupPropName)) {
            [securitygroup setObject:@"指定朋友可见" forKey:@"securitygroupPropName"];
        }else{
            [securitygroup setObject:groupPropName forKey:@"securitygroupPropName"];
        }
        
        NSMutableArray * postArray = [[NSMutableArray alloc] init];
        for (DTieModel * tieModel in posts) {
            NSMutableDictionary * post = [[NSMutableDictionary alloc] init];
            [post setObject:@(tieModel.cid) forKey:@"securitymemberId"];
            if (groupId) {
                [post setObject:@(groupId) forKey:@"securitygroupId"];
            }
            [post setObject:@(1) forKey:@"securitymemberType"];
            [post setObject:@(tieModel.createTime) forKey:@"createTime"];
            [post setObject:@(0) forKey:@"deleteFlg"];
            [postArray addObject:post];
        }
        
        NSMutableArray * userArray = [[NSMutableArray alloc] init];
        for (UserModel * userModel in friends) {
            NSMutableDictionary * user = [[NSMutableDictionary alloc] init];
            [user setObject:@(userModel.cid) forKey:@"securitymemberId"];
            if (groupId) {
                [user setObject:@(groupId) forKey:@"securitygroupId"];
            }
            [user setObject:@(3) forKey:@"securitymemberType"];
            [user setObject:@(0) forKey:@"deleteFlg"];
            [userArray addObject:user];
        }
        
        [self setValue:securitygroup forParamKey:@"securitygroup"];
        [self setValue:postArray forParamKey:@"posts"];
        [self setValue:userArray forParamKey:@"users"];
        
    }
    return self;
}

@end
