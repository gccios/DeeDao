//
//  SelectSecurityRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/25.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface SelectSecurityRequest : BGNetworkRequest

- (instancetype)initWithSelectPostWith:(NSInteger)groupId;

- (instancetype)initWithSelectUserWith:(NSInteger)groupId;

@end
