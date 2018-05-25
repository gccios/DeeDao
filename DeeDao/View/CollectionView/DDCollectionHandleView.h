//
//  DDCollectionHandleView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/25.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDCollectionHandleView : UICollectionReusableView

@property (nonatomic, copy) void (^handleButtonClicked)(void);
@property (nonatomic, strong) UIButton * handleButton;

- (void)configButtonBackgroundColor:(UIColor *)color title:(NSString *)title;

@end
