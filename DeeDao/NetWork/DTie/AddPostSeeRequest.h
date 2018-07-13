//
//  AddPostSeeRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/7/12.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface AddPostSeeRequest : BGNetworkRequest

- (instancetype)initWithPostID:(NSInteger)postID;

@end
