//
//  NotificationHistoryModel.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/17.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MJExtension.h>

@interface NotificationHistoryModel : NSObject

@property (nonatomic, assign) NSInteger cid;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, assign) double remindLat;
@property (nonatomic, assign) double remindLng;
@property (nonatomic, assign) NSInteger remindTime;

@property (nonatomic, strong) NSArray * postList;

@end
