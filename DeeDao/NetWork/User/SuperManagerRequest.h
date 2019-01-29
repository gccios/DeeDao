//
//  SuperManagerRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2019/1/16.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface SuperManagerRequest : BGNetworkRequest

- (instancetype)initWithPageStart:(NSInteger)pageStart pageSize:(NSInteger)pageSize;

- (instancetype)initFreezeUser:(NSInteger)userID;

- (instancetype)initJubaoWithPageStart:(NSInteger)pageStart pageSize:(NSInteger)pageSize;

- (instancetype)initOnlinePost:(NSInteger)postID onlineFlag:(NSInteger)onlineFlag;

@end

NS_ASSUME_NONNULL_END
