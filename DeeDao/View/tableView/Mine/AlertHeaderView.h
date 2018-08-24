//
//  AlertHeaderView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertHeaderView : UITableViewHeaderFooterView

@property (nonatomic, copy) void (^clickedHandle)(void);

- (void)configWithTitle:(NSString *)title;

- (void)configWithOpenStaus:(BOOL)isOpen;

@end
