//
//  GetTelCodeRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/6/5.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface GetTelCodeRequest : BGNetworkRequest

- (instancetype)initWithTelNumber:(NSString *)telNumber;

@end
