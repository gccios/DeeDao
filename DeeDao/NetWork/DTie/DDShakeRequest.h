//
//  DDShakeRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2019/1/24.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDShakeRequest : BGNetworkRequest

- (instancetype)initWithGroupID:(NSInteger)groupID dataSource:(NSInteger)dateSource times:(NSInteger)times;

@end

NS_ASSUME_NONNULL_END
