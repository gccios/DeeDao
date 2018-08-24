//
//  ChangeWYYStatusRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface ChangeWYYStatusRequest : BGNetworkRequest

- (instancetype)initWithPostID:(NSInteger)postID subType:(NSInteger)subType;

@end
