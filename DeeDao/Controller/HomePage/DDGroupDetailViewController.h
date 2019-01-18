//
//  DDGroupDetailViewController.h
//  DeeDao
//
//  Created by 郭春城 on 2019/1/11.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DDViewController.h"
#import "DDGroupModel.h"

@protocol DDGroupDetailViewControllerDelegate <NSObject>

- (void)userNeedUpdateGroupList;

@end

NS_ASSUME_NONNULL_BEGIN

@interface DDGroupDetailViewController : DDViewController

- (instancetype)initWithModel:(DDGroupModel *)model;

@property (nonatomic, weak) id<DDGroupDetailViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
