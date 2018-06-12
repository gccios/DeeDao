//
//  GetDtieSecurityRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/6/11.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"
#import "DTieModel.h"

@interface GetDtieSecurityRequest : BGNetworkRequest

- (instancetype)initWithModel:(DTieModel *)model;

@end
