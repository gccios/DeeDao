//
//  SaveRemindStatusRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/23.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface SaveRemindStatusRequest : BGNetworkRequest

- (instancetype)initWithId:(NSInteger)remindID concern:(NSInteger)concern collection:(NSInteger)collection wyy:(NSInteger)wyy friend:(NSInteger)ifFriend remindInterval:(NSInteger)remindInterval;

@end
