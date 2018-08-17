//
//  AddPostToSeriesRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/17.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface AddPostToSeriesRequest : BGNetworkRequest

- (instancetype)initWithPostList:(NSArray *)postList seriesID:(NSInteger)seriesID;

@end
