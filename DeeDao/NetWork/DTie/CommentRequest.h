//
//  CommentRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/23.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface CommentRequest : BGNetworkRequest

- (instancetype)initWithPostID:(NSInteger)postId;

@end
