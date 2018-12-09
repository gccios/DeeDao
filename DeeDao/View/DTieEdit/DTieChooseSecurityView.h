//
//  DTieChooseSecurityView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/11/16.
//  Copyright © 2018 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieModel.h"

@interface DTieChooseSecurityView : UIView

- (instancetype)initWithFrame:(CGRect)frame model:(DTieModel *)model;

- (void)show;

@end

