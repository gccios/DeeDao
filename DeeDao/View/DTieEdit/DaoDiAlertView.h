//
//  DaoDiAlertView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/14.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DaoDiAlertView : UIView

@property (nonatomic, copy) void (^handleButtonClicked)(void);

- (void)show;

@end
