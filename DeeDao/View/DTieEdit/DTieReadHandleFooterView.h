//
//  DTieReadHandleFooterView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/6/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieModel.h"

@interface DTieReadHandleFooterView : UITableViewHeaderFooterView

@property (nonatomic, copy) void (^handleButtonDidClicked)(void);
@property (nonatomic, copy) void (^addButtonDidClickedHandle)(void);
@property (nonatomic, copy) void (^backButtonDidClicked)(void);

- (void)configWithModel:(DTieModel *)model;

- (void)needBackHomeButton;

- (void)configWithYaoyueModel:(NSArray *)models;

@end
