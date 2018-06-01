//
//  SecurityGroupModel.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/23.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MJExtension.h>

@interface SecurityGroupModel : NSObject

@property (nonatomic, assign) NSInteger createPerson;
@property (nonatomic, assign) NSInteger deleteFlg;
@property (nonatomic, assign) NSInteger cid;
@property (nonatomic, copy) NSString * securitygroupName;
@property (nonatomic, copy) NSString * securitygroupPropName;
@property (nonatomic, assign) NSInteger createTime;

@property (nonatomic, assign) NSInteger landAccountFlg;

@property (nonatomic, assign) BOOL isChoose;
@property (nonatomic, assign) BOOL isNotification;

@end
