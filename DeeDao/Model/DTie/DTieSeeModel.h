//
//  DTieSeeModel.h
//  DeeDao
//
//  Created by 郭春城 on 2018/7/12.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MJExtension.h>

@interface DTieSeeModel : NSObject

@property (nonatomic, assign) NSInteger browserUserId;
@property (nonatomic, assign) NSInteger countPerson;
@property (nonatomic, assign) NSInteger countTime;
@property (nonatomic, copy) NSString * createAddress;
@property (nonatomic, assign) double createAddressLat;
@property (nonatomic, assign) double createAddressLng;
@property (nonatomic, copy) NSString * createCity;
@property (nonatomic, assign) NSInteger createTime;
@property (nonatomic, assign) NSInteger cid;
@property (nonatomic, assign) NSInteger postId;

@end
