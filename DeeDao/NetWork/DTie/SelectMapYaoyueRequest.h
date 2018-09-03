//
//  SelectMapYaoyueRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/7/26.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface SelectMapYaoyueRequest : BGNetworkRequest

- (instancetype)initWithFriendList:(NSArray *)friendList lat1:(double)lat1 lng1:(double)lng1 lat2:(double)lat2 lng2:(double)lng2;

@end
