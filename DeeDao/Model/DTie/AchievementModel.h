//
//  AchievementModel.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AchievementModel : NSObject

@property (nonatomic, assign) NSInteger cid;
@property (nonatomic, assign) NSInteger medalObjectId;
@property (nonatomic, assign) NSInteger medalObjectType;
@property (nonatomic, assign) NSInteger createPerson;
@property (nonatomic, copy) NSString * medalObjectTitle;
@property (nonatomic, copy) NSString * medalObjectImg;
@property (nonatomic, copy) NSString * medalObjectUsername;
@property (nonatomic, assign) NSInteger createTime;

@property (nonatomic, strong) NSArray * details;

@end
