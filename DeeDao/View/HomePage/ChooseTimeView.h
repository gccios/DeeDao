//
//  ChooseTimeView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/15.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseTimeView : UIView

@property (nonatomic, copy) void (^handleButtonClicked)(NSInteger minTime, NSInteger maxTime);

- (void)show;

@end
