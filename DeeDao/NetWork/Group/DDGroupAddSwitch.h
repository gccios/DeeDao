//
//  DDGroupAddSwitch.h
//  DeeDao
//
//  Created by 郭春城 on 2019/1/15.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDGroupAddSwitch : BGNetworkRequest

- (instancetype)initPostSwitchWithID:(NSInteger)postID state:(NSInteger)state;

@end

NS_ASSUME_NONNULL_END
