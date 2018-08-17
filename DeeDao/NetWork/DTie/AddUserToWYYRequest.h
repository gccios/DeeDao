//
//  AddUserToWYYRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/17.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface AddUserToWYYRequest : BGNetworkRequest

- (instancetype)initWithUserList:(NSArray *)userList postId:(NSInteger)postId;

@end
