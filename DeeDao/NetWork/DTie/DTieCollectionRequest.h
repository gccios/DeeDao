//
//  DTieCollectionRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface DTieCollectionRequest : BGNetworkRequest

- (instancetype)initWithPostID:(NSInteger)postId type:(NSInteger)type subType:(NSInteger)subType remark:(NSString *)remark;

@end
