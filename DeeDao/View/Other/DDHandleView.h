//
//  DDHandleView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDHandleButton.h"

@protocol DDHandleViewDelegate <NSObject>

- (void)handleViewDidClickedYaoyue;
- (void)handleViewDidClickedShoucang;
- (void)handleViewDidClickedDazhaohu;

@end

@interface DDHandleView : UIView

@property (nonatomic, weak) id<DDHandleViewDelegate> delegate;

@property (nonatomic, strong) DDHandleButton * yaoyueButton;
@property (nonatomic, strong) DDHandleButton * shoucangButton;
@property (nonatomic, strong) DDHandleButton * dazhaohuButton;

@end
