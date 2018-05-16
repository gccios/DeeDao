//
//  DTieListRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/16.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface DTieListRequest : BGNetworkRequest

- (instancetype)initWithStart:(NSInteger)start length:(NSInteger)length;

@end
