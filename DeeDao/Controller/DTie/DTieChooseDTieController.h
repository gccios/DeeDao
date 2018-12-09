//
//  DTieChooseDTieController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/7/25.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"

@protocol DTieChooseDTieControllerDelegate <NSObject>

- (void)didChooseDtie:(NSArray *)array;

- (void)didSingleChooseDtie:(NSArray *)array;

@end

@interface DTieChooseDTieController : DDViewController

@property (nonatomic, weak) id<DTieChooseDTieControllerDelegate> delegate;

@property (nonatomic, strong) NSMutableArray * chooseSource;

@property (nonatomic, assign) BOOL isSingle;

@end
