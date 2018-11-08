//
//  DTieQuanXianViewController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/6/25.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"

@protocol DTieQuanXianViewControllerDelegate <NSObject>

- (void)DTieQuanxianDidCompleteWith:(NSArray *)source landAccountFlg:(NSInteger)landAccountFlg;

@end

@interface DTieQuanXianViewController : DDViewController

@property (nonatomic, weak) id<DTieQuanXianViewControllerDelegate> delegate;

- (void)delegateShouldBlock;

- (void)configWithType:(NSInteger)type;

@end
