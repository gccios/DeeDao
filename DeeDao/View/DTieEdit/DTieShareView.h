//
//  DTieShareView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/6/5.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DTieShareDelegate <NSObject>

- (void)DTieShareDidSelectIndex:(NSInteger)index;

@end

@interface DTieShareView : UIView

@property (nonatomic, weak) id<DTieShareDelegate> delegate;

- (instancetype)initCreatePostWithFrame:(CGRect)frame;

- (void)show;

@end
