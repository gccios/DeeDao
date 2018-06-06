//
//  LiuYanViewController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"

@protocol LiuyanDidComplete <NSObject>

- (void)liuyanDidComplete;

@end

@interface LiuYanViewController : DDViewController

@property (nonatomic, weak) id<LiuyanDidComplete> delegate;
- (instancetype)initWithPostID:(NSInteger)postId commentId:(NSInteger)commentId;

@end
