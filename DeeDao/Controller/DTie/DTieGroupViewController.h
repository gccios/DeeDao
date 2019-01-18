//
//  DTieGroupViewController.h
//  DeeDao
//
//  Created by 郭春城 on 2019/1/14.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DDViewController.h"
#import "DTieModel.h"

@protocol DTieGroupViewControllerDelegate <NSObject>

- (void)DTieGroupNeedUpdate;

@end

NS_ASSUME_NONNULL_BEGIN

@interface DTieGroupViewController : DDViewController

@property (nonatomic, weak) id<DTieGroupViewControllerDelegate> delegate;

- (instancetype)initWithModel:(DTieModel *)model;

@end

NS_ASSUME_NONNULL_END
