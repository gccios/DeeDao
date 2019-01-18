//
//  DDCreateGroupViewController.h
//  DeeDao
//
//  Created by 郭春城 on 2019/1/8.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DDViewController.h"

@protocol DDCreateGroupViewControllerDelegate <NSObject>

- (void)groupDidCreate;

@end

NS_ASSUME_NONNULL_BEGIN

@interface DDCreateGroupViewController : DDViewController

@property (nonatomic, weak) id<DDCreateGroupViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
