//
//  DeletePostFromSeriesRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/23.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface DeletePostFromSeriesRequest : BGNetworkRequest

- (instancetype)initWithPostID:(NSInteger)postID;

@end
