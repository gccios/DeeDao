//
//  DeleteSecurityRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/25.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface DeleteSecurityRequest : BGNetworkRequest

- (instancetype)initWithGroupID:(NSInteger)groupId;

@end
