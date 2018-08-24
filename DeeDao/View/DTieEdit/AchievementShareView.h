//
//  AchievementShareView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AchievementModel.h"

@interface AchievementShareView : UIView

- (instancetype)initWithAchievementModel:(AchievementModel *)model currentImage:(UIImage *)image type:(NSInteger)type;
- (void)startShare;

@end
