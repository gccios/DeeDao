//
//  DTieDetailRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/16.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface DTieDetailRequest : BGNetworkRequest

- (instancetype)initWithID:(NSInteger)cid type:(NSInteger)type start:(NSInteger)start length:(NSInteger)length;

@end
