//
//  MapShowNotificationView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/9/3.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieModel.h"

@interface MapShowNotificationView : UIView

- (instancetype)initWithModel:(DTieModel *)model;

- (void)show;

@end
