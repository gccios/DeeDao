//
//  DDFriendTableHeaderView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/14.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDFriendTableHeaderView : UITableViewHeaderFooterView

- (void)configWithPre:(NSString *)pre;

- (void)configWithPre:(NSString *)pre title:(NSString *)title;

- (void)configWithTitle:(NSString *)title;

@end
