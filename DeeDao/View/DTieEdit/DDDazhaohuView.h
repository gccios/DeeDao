//
//  DDDazhaohuView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/6/5.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDDazhaohuView : UIView

@property (nonatomic, copy) void (^block)(NSString * text);

- (void)show;

@end
