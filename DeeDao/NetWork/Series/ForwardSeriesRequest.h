//
//  ForwardSeriesRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/13.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface ForwardSeriesRequest : BGNetworkRequest

- (instancetype)initWithSeriesID:(NSInteger)seriesID userList:(NSArray *)userList;

@end
