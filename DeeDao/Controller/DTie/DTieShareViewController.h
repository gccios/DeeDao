//
//  DTieShareViewController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/28.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"

@interface DTieShareViewController : DDViewController

@property (nonatomic, strong) NSMutableArray * shareList;

+ (instancetype)sharedViewController;

- (instancetype)insertShareList:(NSMutableArray *)shareList;

- (instancetype)insertShareList:(NSMutableArray *)shareList title:(NSString *)title pflg:(BOOL)pflg postId:(NSInteger)postId;

@end
