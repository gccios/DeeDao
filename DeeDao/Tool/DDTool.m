//
//  DDTool.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDTool.h"
#import "UserManager.h"
#import <WXApi.h>
#import <BGNetworkManager.h>
#import "DDNetworkConfiguration.h"

@implementation DDTool

+ (void)configApplication
{
    [[BGNetworkManager sharedManager] setNetworkConfiguration:[DDNetworkConfiguration configuration]];
    
    [WXApi registerApp:WeChatAPPKey];
    
    //配置用户信息
    if ([[NSFileManager defaultManager] fileExistsAtPath:DDUserInfoPath]) {
        NSDictionary * userInfo = [NSDictionary dictionaryWithContentsOfFile:DDUserInfoPath];
        if (userInfo && [userInfo isKindOfClass:[NSDictionary class]]) {
            
            [[UserManager shareManager] loginWithDictionary:userInfo];
            
        }else {
            
        }
    }
    
    [[UITableView appearance] setEstimatedRowHeight:0];
    [[UITableView appearance] setEstimatedSectionFooterHeight:0];
    [[UITableView appearance] setEstimatedSectionHeaderHeight:0];
}

@end
