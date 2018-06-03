//
//  DTieDeleteRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/6/3.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface DTieDeleteRequest : BGNetworkRequest

- (instancetype)initWithPostId:(NSInteger)postID;

@end
