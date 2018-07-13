//
//  UserMailModel.h
//  DeeDao
//
//  Created by 郭春城 on 2018/7/12.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MJExtension.h>

@interface UserMailModel : NSObject

@property (nonatomic, assign) NSInteger cid;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, copy) NSString * nickname;
@property (nonatomic, assign) NSInteger bloggerFlg;
@property (nonatomic, copy) NSString * portraituri;
@property (nonatomic, assign) NSInteger ifFollowedFlg;
@property (nonatomic, assign) NSInteger ifFriendFlg;
@property (nonatomic, assign) NSInteger createdat;

@end
