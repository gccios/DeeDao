//
//  DDAuthorGroupDetailController.h
//  DeeDao
//
//  Created by 郭春城 on 2019/1/10.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DDViewController.h"
#import "DDGroupModel.h"

@protocol DDAuthorGroupDetailControllerDelegate <NSObject>

- (void)authorNeedUpdateGroupList;

@end

NS_ASSUME_NONNULL_BEGIN

@interface DDAuthorGroupDetailController : DDViewController

@property (nonatomic, weak) id<DDAuthorGroupDetailControllerDelegate> delegate;

- (instancetype)initWithModel:(DDGroupModel *)model;

@end

NS_ASSUME_NONNULL_END
