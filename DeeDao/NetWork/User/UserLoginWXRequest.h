//
//  UserLoginWXRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface UserLoginWXRequest : BGNetworkRequest

- (instancetype)initWithWeCode:(NSString *)code;

@end
