//
//  ChooseCategoryView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/16.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseCategoryView : UIView

@property (nonatomic, copy) void (^handleButtonClicked)(NSInteger tag);

- (void)show;

@end
