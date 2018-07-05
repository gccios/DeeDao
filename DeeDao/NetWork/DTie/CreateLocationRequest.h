//
//  CreateLocationRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/7/5.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface CreateLocationRequest : BGNetworkRequest

- (instancetype)initWithAddress:(NSString *)address name:(NSString *)name lat:(double)lat lng:(double)lng remark:(NSString *)remark;

@end
