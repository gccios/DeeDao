//
//  SaveFriendOrConcernRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface SaveFriendOrConcernRequest : BGNetworkRequest

- (instancetype)initWithHandleFriendId:(NSInteger)userId andIsAdd:(BOOL)isAdd;

- (instancetype)initWithHandleConcernId:(NSInteger)userId andIsAdd:(BOOL)isAdd;

@end
