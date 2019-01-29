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

@property (nonatomic, assign) NSInteger WYYSelectType;

@property (nonatomic, copy) void (^handleButtonDidClicked)(void);
@property (nonatomic, copy) void (^addButtonDidClickedHandle)(void);
@property (nonatomic, copy) void (^leftHandleButtonBlock)(void);
@property (nonatomic, copy) void (^locationButtonDidClicked)(void);
@property (nonatomic, copy) void (^rightHandleButtonBlock)(void);
@property (nonatomic, copy) void (^backHandleButtonBlock)(void);
@property (nonatomic, copy) void (^jubaoButtonBlock)(void);
@property (nonatomic, copy) void (^selectButtonDidClicked)(NSInteger type);

- (void)configWithModel:(DTieModel *)model;

- (void)needBackHomeButton;

- (void)configWithYaoyueModel:(NSArray *)models;

- (void)configWithWacthPhotos:(NSArray *)models;

- (void)hiddenWithRemark;

@end
