//
//  AddOrUpdateSecurityRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/25.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface AddOrUpdateSecurityRequest : BGNetworkRequest

- (instancetype)initWithCreatePerson:(NSInteger)createPerson deleteFlg:(NSInteger)deleteFlg groupId:(NSInteger)groupId groupName:(NSString *)groupName groupPropName:(NSString *)groupPropName posts:(NSArray *)posts friends:(NSArray *)friends;

@end
