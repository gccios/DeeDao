//
//  DTiePOIRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/6/7.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface DTiePOIRequest : BGNetworkRequest

- (instancetype)initWithLat:(double)lat lng:(double)lng;

@end
