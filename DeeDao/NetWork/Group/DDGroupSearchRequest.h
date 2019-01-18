//
//  DDGroupSearchRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2019/1/15.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDGroupSearchRequest : BGNetworkRequest

- (instancetype)initSearchGroupWithKeyWord:(NSString *)keyWord;

- (instancetype)initSearchPublicWithKeyWord:(NSString *)keyWord;

@end

NS_ASSUME_NONNULL_END
