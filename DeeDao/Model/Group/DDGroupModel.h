//
//  DDGroupModel.h
//  DeeDao
//
//  Created by 郭春城 on 2019/1/10.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MJExtension.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDGroupModel : NSObject

@property (nonatomic, assign) BOOL isSystem;

@property (nonatomic, assign) NSInteger cid;
@property (nonatomic, copy) NSString * groupName;
@property (nonatomic, copy) NSString * groupPic;
@property (nonatomic, copy) NSString * remark;
@property (nonatomic, copy) NSString * managerName;
@property (nonatomic, copy) NSString * managerPortraitUri;
@property (nonatomic, assign) NSInteger postFlag;
@property (nonatomic, assign) NSInteger freezeState;
@property (nonatomic, assign) NSInteger groupState; //1上线，0下线
@property (nonatomic, assign) NSInteger groupSearchState; //0公开，1私密
@property (nonatomic, assign) NSInteger groupCreateDate;
@property (nonatomic, assign) NSInteger groupCreateUser;
@property (nonatomic, assign) NSInteger joinAuthorize; //0不用批准，1需要批准
@property (nonatomic, assign) NSInteger readWriteAuthorize; //0没有读写，1有读写需审批，2有读写不需审批，3只读
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger userFlag;

@property (nonatomic, assign) NSInteger newFlag;

- (instancetype)initWithMy;
- (instancetype)initWithPublic;
- (instancetype)initWithMyWYY;
- (instancetype)initWithMyCollect;
- (instancetype)initWithMyHome;

- (instancetype)initWithCreate;

@end

NS_ASSUME_NONNULL_END
