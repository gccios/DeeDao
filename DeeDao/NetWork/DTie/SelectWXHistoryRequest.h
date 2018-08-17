//
//  SelectWXHistoryRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/18.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface SelectWXHistoryRequest : BGNetworkRequest

- (instancetype)initWithStart:(NSInteger)start size:(NSInteger)size;

@end
