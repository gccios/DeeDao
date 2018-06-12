//
//  MailModel.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/18.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MJExtension.h>

typedef enum : NSUInteger {
    MailModelType_System,
    MailModelType_HuDong,
    MailModelType_DTie,
    MailModelType_Other
} MailModelType;

@interface MailModel : NSObject

@property (nonatomic, assign) NSInteger type;

@property (nonatomic, copy) NSString * portraitUri;
@property (nonatomic, copy) NSString * nickName;

@property (nonatomic, copy) NSString * postFirstPicture;
@property (nonatomic, assign) NSInteger postId;
@property (nonatomic, assign) NSInteger createPerson;
@property (nonatomic, assign) NSInteger createTime;
@property (nonatomic, assign) NSInteger deleteFlg;
@property (nonatomic, assign) NSInteger cid;
@property (nonatomic, copy) NSString * mailContent;
@property (nonatomic, assign) NSInteger mailIfread;
@property (nonatomic, assign) NSInteger mailMainId;
@property (nonatomic, copy) NSString * mailPic;
@property (nonatomic, assign) NSInteger mailRevId;
@property (nonatomic, assign) NSInteger mailSendId;
@property (nonatomic, copy) NSString * mailSign;
@property (nonatomic, assign) NSInteger mailTargetId;
@property (nonatomic, copy) NSString * mailTitle;
@property (nonatomic, assign) NSInteger mailTypeId;
@property (nonatomic, copy) NSString * mailUrl;
@property (nonatomic, assign) NSInteger updatePerson;
@property (nonatomic, copy) NSString * mailPostSummary;
@property (nonatomic, assign) NSInteger updateTime;

+ (NSString *)getTitleWithMailTypeId:(NSInteger)typeId;

@end
