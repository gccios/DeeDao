//
//  SeriesDetailRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SeriesDetailRequest.h"

@implementation SeriesDetailRequest

- (instancetype)initWithSeriesID:(NSInteger)seriesId
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = [NSString stringWithFormat:@"series/showSeriesDetail?seriesId=%ld", seriesId];
    }
    return self;
}

@end
