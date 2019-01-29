//
//  UserModel.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MJExtension.h>

@interface UserModel : NSObject

@property (nonatomic, copy) NSString * country;
@property (nonatomic, copy) NSString * city;
@property (nonatomic, copy) NSString * province;
@property (nonatomic, assign) NSInteger groupcount;
@property (nonatomic, assign) NSInteger cid;
@property (nonatomic, copy) NSString * openid;
@property (nonatomic, copy) NSString * unionid;
@property (nonatomic, copy) NSString * nickname;
@property (nonatomic, copy) NSString * secondNickname;
@property (nonatomic, copy) NSString * sex;
@property (nonatomic, copy) NSString * portraituri;
@property (nonatomic, assign) NSInteger createdat;
@property (nonatomic, assign) NSInteger updatedat;
@property (nonatomic, copy) NSString * rongcloudtoken;
@property (nonatomic, assign) NSInteger timestamp;
@property (nonatomic, copy) NSString * phone;
@property (nonatomic, copy) NSString * signature;
@property (nonatomic, strong) NSArray * postBeanList;
@property (nonatomic, assign) NSInteger bloggerFlg;
@property (nonatomic, copy) NSString * backgroundImage;

@property (nonatomic, copy) NSString * firstLetter;

@property (nonatomic, assign) NSInteger concernFlg; //关注
@property (nonatomic, assign) NSInteger friendFlg; //好友
@property (nonatomic, assign) NSInteger selfFlg; //本人

//用于群的成员管理
@property (nonatomic, assign) NSInteger groupID;
@property (nonatomic, copy) NSString * groupListID;
@property (nonatomic, assign) NSInteger authority;

@end
