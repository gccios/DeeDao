//
//  DTieEditRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/11/15.
//  Copyright © 2018 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface DTieEditRequest : BGNetworkRequest

- (instancetype)initWithTitle:(NSString *)title postID:(NSInteger)postID;

- (instancetype)initWithAddress:(NSString *)address building:(NSString *)building lat:(double)lat lng:(double)lng postID:(NSInteger)postID;

- (instancetype)initWithTime:(NSInteger)time postID:(NSInteger)postID;

- (instancetype)initWithStaus:(NSInteger)status postID:(NSInteger)postID;

- (instancetype)initWithAccountFlg:(NSInteger)accountFlg groupList:(NSArray *)groupList postID:(NSInteger)postID;

@end
