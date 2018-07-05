//
//  GetUserCreateLocationRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/7/5.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface GetUserCreateLocationRequest : BGNetworkRequest

- (instancetype)initWithKeyWord:(NSString *)keyWord lat:(double)lat lng:(double)lng;

@end
